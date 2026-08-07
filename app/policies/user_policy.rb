# frozen_string_literal: true

# 用户管理授权（canonical 示例）
# 每个操作只声明所需权限点，判定交给 user.has_permission?（角色 → 权限聚合）。
class UserPolicy < ApplicationPolicy
  def index?  = user.has_permission?("system:user:list")
  def show?   = user.has_permission?("system:user:list")
  def create? = user.has_permission?("system:user:create")
  def update? = user.has_permission?("system:user:edit")
  def destroy? = user.has_permission?("system:user:delete")

  # 列表/读取作用域所需的权限点（普通用户无此点则 scope 返回空集）。
  def required_scope_permission = "system:user:list"
end
