# frozen_string_literal: true

module Admin
  # 后台鉴权基类（阶段 1）：在 InertiaController 之上叠加 ActionPolicy 验权。
  # - 登录检查复用 ApplicationController#require_login（未登录直接跳登录页）。
  # - include ActionPolicy::Controller 提供 authorize! / allowed_to?
  #   （railtie 已配置 `authorize :user, through: :current_user`，自动注入当前用户到策略）
  class BaseController < InertiaController
    include ActionPolicy::Controller

    before_action :require_login
    before_action :mark_operation_start
    # 自动记录后台操作日志（查看日志自身除外，避免噪声）。
    after_action :record_operation_log, if: :operation_loggable?

    # 桥接 Pundit 风格命名到 ActionPolicy 的 authorized_scope：
    # 让 pages_controller 用 policy_scope(User.all, with: UserPolicy) 表达 IDOR 作用域，
    # 底层走 ActionPolicy 的 scope_for :active_record_relation 机制。
    def policy_scope(record, **options)
      authorized_scope(record, **options)
    end

    private

    # ---- 操作日志自动记录 ----
    def mark_operation_start
      @operation_start = Time.current
    end

    # 跳过查看日志自身；仅对已登录后台操作记录。
    def operation_loggable?
      %w[operation_logs login_logs].exclude?(controller_name) && logged_in?
    end

    def record_operation_log
      OperationLog.create!(
        admin_user_id: current_user&.id,
        username: current_user&.username,
        ip: request.remote_ip,
        request_method: request.request_method,
        path: request.fullpath,
        action: action_name,
        title: "#{controller_name}##{action_name}",
        status: response.successful? ? "success" : "fail",
        duration_ms: ((Time.current - @operation_start) * 1000).round
      )
    rescue StandardError => e
      Rails.logger.warn "操作日志写入失败：#{e.message}"
    end
  end
end
