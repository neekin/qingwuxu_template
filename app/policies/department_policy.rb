# frozen_string_literal: true

# 部门管理页授权（轻量 policy：按权限点 departments:view 判定）。
class DepartmentPolicy < ApplicationPolicy
  def view? = user.has_permission?("departments:view")
end
