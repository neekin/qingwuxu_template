# frozen_string_literal: true

# 登录日志页授权（轻量 policy：按权限点 login_logs:view 判定）。
class LoginLogPolicy < ApplicationPolicy
  def view? = user.has_permission?("login_logs:view")
end
