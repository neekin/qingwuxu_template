# frozen_string_literal: true

# 后台仪表盘页授权（轻量 policy：无专属 resource，按权限点 dashboard:view 判定）。
class DashboardPolicy < ApplicationPolicy
  def view? = user.has_permission?("dashboard:view")
end
