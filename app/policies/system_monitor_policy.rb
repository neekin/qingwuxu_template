# frozen_string_literal: true

# 系统监控看板授权（轻量 policy：按权限点 monitor:server:view 判定）。
class SystemMonitorPolicy < ApplicationPolicy
  def view? = user.has_permission?("monitor:server:view")
end
