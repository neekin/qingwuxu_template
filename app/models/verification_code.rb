# frozen_string_literal: true

# 验证码（DB 存储，替代 redis；本环境无 redis，sqlite 可跑）。
# 覆盖 手机(sms)/邮箱(email) 两种通道，用途含 登录/注册/改密。
class VerificationCode < ApplicationRecord
  CHANNELS = %w[sms email].freeze
  PURPOSES = %w[login register reset_password].freeze

  validates :receiver, presence: true
  validates :channel, inclusion: { in: CHANNELS }
  validates :purpose, inclusion: { in: PURPOSES }
  validates :code, presence: true
  validates :expires_at, presence: true

  # 生成并落库（带 60s 重发限频 + 清理旧码）。触发限频抛 RateLimitError。
  def self.generate!(receiver:, channel:, purpose:)
    pending = where(receiver: receiver, channel: channel, purpose: purpose)
                .where(used_at: nil)
                .where("expires_at > ?", Time.current)
                .where("created_at > ?", 60.seconds.ago)
                .order(created_at: :desc)
                .first
    raise RateLimitError, "验证码发送过于频繁，请稍后再试" if pending

    where(receiver: receiver, channel: channel, purpose: purpose).delete_all

    code = format("%06d", SecureRandom.random_number(1_000_000))
    create!(
      receiver: receiver,
      channel: channel,
      purpose: purpose,
      code: code,
      expires_at: 5.minutes.from_now,
      attempts: 0
    )
  end

  # 校验：未使用、未过期、错误次数 < 5、码一致 → 标记已用返回 true。
  def verify?(input)
    return false if used? || expired?
    return false if attempts >= 5
    unless code == input.to_s.strip
      increment!(:attempts)
      return false
    end
    update!(used_at: Time.current)
    true
  end

  def used?
    used_at.present?
  end

  def expired?
    expires_at < Time.current
  end

  class RateLimitError < StandardError; end
end
