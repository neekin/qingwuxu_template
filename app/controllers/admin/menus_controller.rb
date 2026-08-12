# frozen_string_literal: true

module Admin
  # 菜单管理（真实写路径：create/update/destroy 走 Inertia POST/PUT/DELETE）。
  # 后端范式同用户/角色/部门：成功 → redirect_to index；校验失败 → 422 + errors。
  # 树形自引用：删除含子项的菜单先拦截，避免悬空 parent_id。
  class MenusController < BaseController
    def index
      authorize! Menu, to: :index?
      render inertia: "admin/menus/index", props: menus_props
    end

    def create
      authorize! Menu, to: :create?
      menu = Menu.new(menu_params)
      if menu.save
        redirect_to admin_menus_path
      else
        render inertia: "admin/menus/index",
               props: menus_props.merge(errors: menu.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def update
      authorize! Menu, to: :update?
      menu = Menu.find(params[:id])
      if menu.update(menu_params)
        redirect_to admin_menus_path
      else
        render inertia: "admin/menus/index",
               props: menus_props.merge(errors: menu.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize! Menu, to: :destroy?
      menu = Menu.find(params[:id])
      # 含子项禁止删除，避免悬空 parent_id
      if menu.children.exists?
        render inertia: "admin/menus/index",
               props: menus_props.merge(errors: ["请先删除该菜单下的子项"]),
               status: :unprocessable_entity
        return
      end
      menu.destroy
      redirect_to admin_menus_path
    end

    private

    def menus_props
      menus = Menu.order(:sort, :id)
      {
        menus: menus.map do |m|
          {
            id: m.id,
            name: m.name,
            route: m.route,
            permission_code: m.permission_code,
            menu_type: m.menu_type,
            status: m.status,
            icon: m.icon,
            component: m.component,
            parent_id: m.parent_id,
            parent_name: m.parent&.name,
            sort: m.sort
          }
        end,
        # 父级下拉选项（仅目录/菜单可作为父级；按钮无子项）
        all_menus: menus.where(menu_type: %i[catalog menu]).map { |m| { id: m.id, name: m.name } }
      }
    end

    # 前端 ProListPage 发裸 values；enum 字段传字符串由 Rails 自动转换；
    # parent_id 空串由整数类型转换归 nil。
    def menu_params
      params.permit(:name, :route, :permission_code, :menu_type, :status, :icon, :component, :parent_id, :sort)
    end
  end
end
