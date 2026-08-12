# frozen_string_literal: true

module Admin
  # 系统监控看板（只读总览：Solid 三件套 Queue/Cache/Cable 状态 + 应用运行指标）。
  # 数据来源：
  #  - SolidQueue 各状态分表（ready/scheduled/claimed/failed/finished）
  #  - SolidCache::Entry（缓存条目）
  #  - SolidCable::Message（WebSocket 消息）
  #  - 应用模型：在线会话 / 操作日志 / 登录日志
  class SystemMonitorController < BaseController
    def index
      authorize! nil, to: :view?, with: SystemMonitorPolicy
      render inertia: "admin/system-monitor/index", props: monitor_props
    end

    private

    def monitor_props
      {
        queue: {
          pending: SolidQueue::ReadyExecution.count + SolidQueue::ScheduledExecution.count,
          running: SolidQueue::ClaimedExecution.count,
          failed: SolidQueue::FailedExecution.count,
          finished: SolidQueue::Job.where.not(finished_at: nil).count
        },
        cache: { entries: SolidCache::Entry.count },
        cable: { messages: SolidCable::Message.count },
        app: {
          online_users: LoginSession.online.count,
          operation_logs_today: OperationLog.where("created_at > ?", 24.hours.ago).count,
          login_logs_today: LoginLog.where("created_at > ?", 24.hours.ago).count
        }
      }
    end
  end
end
