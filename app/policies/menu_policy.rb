# frozen_string_literal: true

# 菜单管理授权（权限点范式：system:menu:*）。
# 最小授权单元是权限点；policy 永远判 user.has_permission?，绝不硬编码角色。
class MenuPolicy < ApplicationPolicy
  def index?   = user.has_permission?("system:menu:list")
  def create?  = user.has_permission?("system:menu:create")
  def update?  = user.has_permission?("system:menu:edit")
  def destroy? = user.has_permission?("system:menu:delete")
end
