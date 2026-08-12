# frozen_string_literal: true

# 示例定时作业：清理 N 天前的登录日志（防止登录日志无限膨胀）。
# 通过 config/recurring.yml 定时触发，也可手动入队：
#   CleanupExpiredLoginLogsJob.perform_later
class CleanupExpiredLoginLogsJob < ApplicationJob
  queue_as :default

  # 默认保留 90 天；可在 perform_later(retention_days:) 时覆盖。
  def perform(retention_days: 90)
    cutoff = retention_days.to_i.days.ago.beginning_of_day
    deleted = LoginLog.where("created_at < ?", cutoff).delete_all
    Rails.logger.info "CleanupExpiredLoginLogsJob：清理 #{deleted} 条 #{retention_days} 天前的登录日志"
    deleted
  end
end
