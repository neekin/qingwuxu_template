# frozen_string_literal: true

module Admin
  # 在线用户（监控视图：列出当前在线会话，支持强制下线）。
  # 强制下线 = 删除 LoginSession 记录；目标用户下次请求令牌校验失败即被弹回登录页。
  class OnlineUsersController < BaseController
    def index
      authorize! LoginSession, to: :index?
      render inertia: "admin/online-users/index", props: online_users_props
    end

    def destroy
      authorize! LoginSession, to: :destroy?
      target = scoped.find(params[:id])
      # 禁止强制下线自己的当前会话（比对令牌，避免把自己踢下线）。
      if target.token == current_login_session&.token
        render inertia: "admin/online-users/index",
               props: online_users_props.merge(errors: ["不能强制下线当前会话"]),
               status: :unprocessable_entity
        return
      end
      target.destroy
      redirect_to admin_online_users_path
    end

    private

    # IDOR 防线：列表/写操作都过 policy_scope（超管全量 / 普通按权限过滤）。
    def scoped
      policy_scope(LoginSession.all, with: OnlineUserPolicy)
    end

    def online_users_props
      sessions = scoped.online.preload(user: :department)
      {
        online_users: sessions.map do |s|
          {
            id: s.id,
            username: s.user&.username,
            phone: s.user&.phone,
            department_name: s.user&.department&.name,
            ip: s.ip,
            created_at: s.created_at.strftime("%Y-%m-%d %H:%M"),
            last_seen_at: s.last_seen_at&.strftime("%Y-%m-%d %H:%M")
          }
        end
      }
    end
  end
end
