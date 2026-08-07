# frozen_string_literal: true

module Admin
  # 后台鉴权基类（阶段 1）：在 InertiaController 之上叠加 ActionPolicy 验权。
  # - 登录检查复用 ApplicationController#require_login（未登录直接跳登录页）。
  # - include ActionPolicy::Controller 提供 authorize! / allowed_to?
  #   （railtie 已配置 `authorize :user, through: :current_user`，自动注入当前用户到策略）
  class BaseController < InertiaController
    include ActionPolicy::Controller

    before_action :require_login

    # 桥接 Pundit 风格命名到 ActionPolicy 的 authorized_scope：
    # 让 pages_controller 用 policy_scope(User.all, with: UserPolicy) 表达 IDOR 作用域，
    # 底层走 ActionPolicy 的 scope_for :active_record_relation 机制。
    def policy_scope(record, **options)
      authorized_scope(record, **options)
    end
  end
end
