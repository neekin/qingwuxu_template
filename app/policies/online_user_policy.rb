# frozen_string_literal: true

# 在线用户授权（监控视图，不绑定部门数据权限）。
# 每个操作只声明所需权限点，判定交给 user.has_permission?（角色 → 权限聚合）。
# LoginSession 无 department_id 列，scope_for 不会按部门收窄，作为全局监控视图。
class OnlineUserPolicy < ApplicationPolicy
  def index?  = user.has_permission?("system:online:list")
  def show?   = user.has_permission?("system:online:list")
  def destroy? = user.has_permission?("system:online:force")

  # 列表/读取作用域所需的权限点（普通用户无此点则 scope 返回空集，IDOR 防线）。
  def required_scope_permission = "system:online:list"
end
