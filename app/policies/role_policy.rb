# frozen_string_literal: true

# 角色管理授权（canonical 示例，与 UserPolicy 同构）
class RolePolicy < ApplicationPolicy
  def index?  = user.has_permission?("system:role:list")
  def show?   = user.has_permission?("system:role:list")
  def create? = user.has_permission?("system:role:create")
  def update? = user.has_permission?("system:role:edit")
  def destroy? = user.has_permission?("system:role:delete")

  # 列表/读取作用域所需的权限点（普通用户无此点则 scope 返回空集）。
  def required_scope_permission = "system:role:list"
end
