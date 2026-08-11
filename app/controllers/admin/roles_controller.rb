# frozen_string_literal: true

module Admin
  # 角色管理（真实写路径：create/update/destroy 走 Inertia POST/PUT/DELETE）。
  # 角色绑定权限点：前端多选 permission_ids，后端清空重建关联。
  class RolesController < BaseController
    def index
      authorize! Role, to: :index?
      render inertia: "admin/roles/index", props: roles_props
    end

    def create
      authorize! Role, to: :create?
      role = Role.new(role_params)
      if role.save
        attach_permissions(role, params[:permission_ids])
        redirect_to admin_roles_path
      else
        render inertia: "admin/roles/index",
               props: roles_props.merge(errors: role.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def update
      authorize! Role, to: :update?
      role = scoped.find(params[:id])
      if role.update(role_params)
        attach_permissions(role, params[:permission_ids])
        redirect_to admin_roles_path
      else
        render inertia: "admin/roles/index",
               props: roles_props.merge(errors: role.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize! Role, to: :destroy?
      role = scoped.find(params[:id])
      # 超管角色不可删（防止权限体系被破坏）
      if role.code == "super_admin"
        render inertia: "admin/roles/index",
               props: roles_props.merge(errors: ["超级管理员角色不可删除"]),
               status: :unprocessable_entity
        return
      end
      role.destroy
      redirect_to admin_roles_path
    end

    private

    def scoped
      policy_scope(Role.all, with: RolePolicy)
    end

    def roles_props
      roles = scoped.includes(:permissions).order(created_at: :asc)
      {
        roles: roles.map do |r|
          {
            id: r.id,
            name: r.name,
            code: r.code,
            remark: r.description,
            permissionCount: r.permissions.size,
            permission_ids: r.permissions.pluck(:id),
            created_at: r.created_at.strftime("%Y-%m-%d %H:%M")
          }
        end,
        # 全部权限点供前端多选（按模块分组）
        all_permissions: Permission.order(:code).map do |p|
          { id: p.id, code: p.code, name: p.name }
        end
      }
    end

    # 前端 ProListPage 发裸 values，用 permit 直接收。
    def role_params
      params.permit(:name, :code, :status, :description, permission_ids: [])
    end

    # 权限点绑定：清空重建（避免重复）。
    def attach_permissions(role, permission_ids)
      ids = Array(permission_ids).map(&:to_i).reject(&:zero?)
      role.permissions = Permission.where(id: ids)
    end
  end
end
