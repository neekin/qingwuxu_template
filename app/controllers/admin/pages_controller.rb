# frozen_string_literal: true

# 后台静态页面控制器（一期：页面渲染壳，数据由前端 mock）
# 真实数据 / 验权将在后续分期接入；此处仅将请求路由到对应 Inertia 页面组件。
module Admin
  class PagesController < InertiaController
    def dashboard
      render_page(:dashboard)
    end

    def users
      render_page(:users)
    end

    def roles
      render_page(:roles)
    end

    def menus
      render_page(:menus)
    end

    def departments
      render_page(:departments)
    end

    def operation_logs
      render_page(:operation_logs)
    end

    def login_logs
      render_page(:login_logs)
    end

    def profile
      render_page(:profile)
    end

    private

    # 将请求转发到 app/frontend/pages/admin/<name>/index.tsx
    # Inertia resolve 规则：name "admin/<name>/index" => 文件 pages/admin/<name>/index.tsx
    def render_page(name)
      render inertia: "admin/#{name}/index"
    end
  end
end
