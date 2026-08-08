# frozen_string_literal: true

# 在线会话记录：每个后台登录会话对应一条记录，用于「在线用户」监控与强制下线。
# 强制下线 = 删除该记录；目标用户下次请求时 ApplicationController#resolve_current_user
# 校验令牌失败，被弹回登录页。
class LoginSession < ApplicationRecord
  # 判定为「在线」的最后访问阈值。
  ONLINE_WITHIN = 30.minutes

  belongs_to :user

  # 自动生成高强度随机令牌（底层 SecureRandom + 唯一索引兜底碰撞）。
  has_secure_token :token

  # 在线：最后访问在阈值内。
  scope :online, -> { where("last_seen_at > ?", ONLINE_WITHIN.ago) }

  # 轻量更新最后访问时间（跳过校验与回调，避免每次请求额外开销）。
  def touch_last_seen
    update_column(:last_seen_at, Time.current)
  end
end
