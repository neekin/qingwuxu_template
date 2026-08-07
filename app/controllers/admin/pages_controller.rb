# frozen_string_literal: true

# 后台静态页面控制器（一期：页面渲染壳，数据由前端 mock）
# 真实数据 / 验权将在后续分期接入；此处仅将请求路由到对应 Inertia 页面组件。
module Admin
  class PagesController < BaseController
    def dashboard
      authorize! nil, to: :view?, with: DashboardPolicy
      render_page(:dashboard)
    end

    # 授权范式（canonical 示例）：按权限点 system:user:list 判定 + 真实数据注入
    def users
      authorize! User, to: :index?
      # IDOR 防线：用 policy_scope 包装查询（超管全量 / 普通按权限过滤，无权限返回空集）
      users = policy_scope(User.all, with: UserPolicy)
                   .includes(:roles).order(created_at: :desc).map do |u|
        {
          id: u.id,
          username: u.username,
          email: u.email,
          phone: u.phone,
          role: u.roles.pluck(:name).join("、"),
          status: u.status,
          super_admin: u.super_admin?,
          created_at: u.created_at.strftime("%Y-%m-%d %H:%M")
        }
      end
      render_page(:users, users: users)
    end

    # 授权范式：按权限点 system:role:list 判定 + 真实数据注入
    def roles
      authorize! Role, to: :index?
      # IDOR 防线：用 policy_scope 包装查询（超管全量 / 普通按权限过滤，无权限返回空集）
      roles = policy_scope(Role.all, with: RolePolicy)
                  .includes(:permissions).order(created_at: :asc).map do |r|
        {
          id: r.id,
          name: r.name,
          code: r.code,
          remark: r.description,
          permissionCount: r.permissions.size,
          created_at: r.created_at.strftime("%Y-%m-%d %H:%M")
        }
      end
      render_page(:roles, roles: roles)
    end

    def menus
      authorize! nil, to: :view?, with: MenuPolicy
      render_page(:menus)
    end

    def departments
      authorize! nil, to: :view?, with: DepartmentPolicy
      render_page(:departments)
    end

    def operation_logs
      authorize! nil, to: :view?, with: OperationLogPolicy
      render_page(:operation_logs)
    end

    def login_logs
      authorize! nil, to: :view?, with: LoginLogPolicy
      render_page(:login_logs)
    end

    def profile
      authorize! nil, to: :view?, with: ProfilePolicy
      render_page(:profile)
    end

    private

    # 将请求转发到 app/frontend/pages/admin/<name>/index.tsx
    # Inertia resolve 规则：name "admin/<name>/index" => 文件 pages/admin/<name>/index.tsx
    def render_page(name, props = {})
      render inertia: "admin/#{name}/index", props: props
    end
  end
end
