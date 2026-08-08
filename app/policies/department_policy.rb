# frozen_string_literal: true

# 部门管理授权。
# 每个操作只声明所需权限点，判定交给 user.has_permission?（角色 → 权限聚合）。
# 部门不绑定部门（无 department_id 列），故数据权限部门过滤不影响部门列表——
# 普通用户无 system:dept:list 则返回空集（最小化），超管短路全量。
class DepartmentPolicy < ApplicationPolicy
  def index?  = user.has_permission?("system:dept:list")
  def show?   = user.has_permission?("system:dept:list")
  def create? = user.has_permission?("system:dept:create")
  def update? = user.has_permission?("system:dept:edit")
  def destroy? = user.has_permission?("system:dept:delete")

  # 列表/读取作用域所需的权限点（普通用户无此点则 scope 返回空集）。
  def required_scope_permission = "system:dept:list"
end
