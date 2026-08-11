# frozen_string_literal: true

module Admin
  # 操作日志（只读审计视图；记录由 BaseController#record_operation_log 自动写入）。
  class OperationLogsController < BaseController
    def index
      authorize! nil, to: :view?, with: OperationLogPolicy
      logs = OperationLog.recent.limit(200)
      render inertia: "admin/operation_logs/index", props: {
        operation_logs: logs.map do |log|
          {
            id: log.id,
            username: log.username,
            ip: log.ip,
            request_method: log.request_method,
            path: log.path,
            action: log.action,
            title: log.title,
            status: log.status,
            duration_ms: log.duration_ms,
            created_at: log.created_at.strftime("%Y-%m-%d %H:%M:%S")
          }
        end
      }
    end
  end
end
