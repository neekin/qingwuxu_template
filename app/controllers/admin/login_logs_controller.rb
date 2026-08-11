# frozen_string_literal: true

module Admin
  # 登录日志（只读审计视图；记录由 SessionsController#create 登录成败时写入）。
  class LoginLogsController < BaseController
    def index
      authorize! nil, to: :view?, with: LoginLogPolicy
      logs = LoginLog.recent.limit(200)
      render inertia: "admin/login_logs/index", props: {
        login_logs: logs.map do |log|
          {
            id: log.id,
            username: log.username,
            ip: log.ip,
            user_agent: log.user_agent,
            login_type: log.login_type,
            status: log.status,
            message: log.message,
            created_at: log.created_at.strftime("%Y-%m-%d %H:%M:%S")
          }
        end
      }
    end
  end
end
