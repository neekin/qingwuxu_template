# frozen_string_literal: true

# 个人资料授权（轻量 policy：个人中心为自服务，登录态即可，统一按 user:profile:view 判定）。
class ProfilePolicy < ApplicationPolicy
  def view?           = user.has_permission?("user:profile:view")
  def update?         = user.has_permission?("user:profile:view")
  def change_password? = user.has_permission?("user:profile:view")
end
