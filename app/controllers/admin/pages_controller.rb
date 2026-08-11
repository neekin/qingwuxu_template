# frozen_string_literal: true

# 后台静态页面控制器（一期：页面渲染壳，数据由前端 mock）
# 真实数据 / 验权将在后续分期接入；此处仅将请求路由到对应 Inertia 页面组件。
module Admin
  class PagesController < BaseController
    def dashboard
      authorize! nil, to: :view?, with: DashboardPolicy
      render_page(:dashboard)
    end

    def menus
      authorize! nil, to: :view?, with: MenuPolicy
      render_page(:menus)
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
