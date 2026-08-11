# frozen_string_literal: true

# 登录日志（后台登录成败审计）。
class LoginLog < ApplicationRecord
  belongs_to :user, optional: true

  scope :recent, -> { order(created_at: :desc) }
end
