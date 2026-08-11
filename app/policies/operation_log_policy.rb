# frozen_string_literal: true

# 操作日志页授权（轻量 policy：按权限点 operation_logs:view 判定）。
class OperationLogPolicy < ApplicationPolicy
  def view? = user.has_permission?("monitor:operlog:list")
end
