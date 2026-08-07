# frozen_string_literal: true

# 个人资料页授权（轻量 policy：按权限点 profile:view 判定）。
class ProfilePolicy < ApplicationPolicy
  def view? = user.has_permission?("profile:view")
end
