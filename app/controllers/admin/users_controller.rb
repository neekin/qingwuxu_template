# frozen_string_literal: true

module Admin
  # 用户管理（真实写路径：create/update/destroy 走 Inertia POST/PUT/DELETE）。
  # 后端范式同字典/部门：成功 → redirect_to index；校验失败 → 422 + errors。
  # 安全约束：禁止删除自己 / 禁止删除最后一个 super_admin / 密码留空不改。
  class UsersController < BaseController
    def index
      authorize! User, to: :index?
      render inertia: "admin/users/index", props: users_props
    end

    def create
      authorize! User, to: :create?
      # role_ids 不是 User 列，且 has_many :through 关联在「未保存」父记录上赋值不可靠；
      # 故先存用户，再绑定角色/部门，确保 user_roles 联结记录落库。
      user = User.new(user_params.except(:role_ids))
      if user.save
        attach_roles(user, params[:role_ids])
        user.update!(department_id: params[:department_id].presence)
        redirect_to admin_users_path
      else
        render inertia: "admin/users/index",
               props: users_props.merge(errors: user.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def update
      authorize! User, to: :update?
      user = scoped.find(params[:id])
      # 密码留空不改（前端编辑表单密码可选）
      attrs = user_params
      attrs.delete(:password) if attrs[:password].blank?
      if user.update(attrs)
        attach_roles(user, params[:role_ids])
        user.update!(department_id: params[:department_id].presence)
        redirect_to admin_users_path
      else
        render inertia: "admin/users/index",
               props: users_props.merge(errors: user.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize! User, to: :destroy?
      user = scoped.find(params[:id])
      # 禁止删除自己
      if user.id == current_user.id
        render inertia: "admin/users/index",
               props: users_props.merge(errors: ["不能删除当前登录用户"]),
               status: :unprocessable_entity
        return
      end
      # 禁止删除最后一个 super_admin（防止失去超管入口）
      if user.super_admin? && User.where(super_admin: true).count <= 1
        render inertia: "admin/users/index",
               props: users_props.merge(errors: ["系统至少需保留一个超级管理员"]),
               status: :unprocessable_entity
        return
      end
      user.destroy
      redirect_to admin_users_path
    end

    private

    # IDOR 防线：列表/写操作都过 policy_scope（超管全量 / 普通按部门过滤）。
    def scoped
      policy_scope(User.all, with: UserPolicy)
    end

    def users_props
      users = scoped.includes(:roles, :department).order(created_at: :desc)
      {
        users: users.map do |u|
          {
            id: u.id,
            username: u.username,
            email: u.email,
            phone: u.phone,
            role: u.roles.pluck(:name).join("、"),
            role_ids: u.roles.pluck(:id),
            department: u.department&.name,
            department_id: u.department_id,
            status: u.status,
            super_admin: u.super_admin?,
            created_at: u.created_at.strftime("%Y-%m-%d %H:%M")
          }
        end,
        # 下拉选项供前端表单使用
        all_roles: Role.where(status: :enabled).order(:id).map { |r| { id: r.id, name: r.name } },
        all_departments: Department.where(status: :enabled).order(:sort).map { |d| { id: d.id, name: d.name } }
      }
    end

    # 前端 ProListPage 发裸 values，用 permit 直接收。password 可选（留空不改）。
    def user_params
      params.permit(:username, :email, :phone, :password, :status, :department_id, role_ids: [])
    end

    # 角色绑定：清空重建（避免重复）。
    def attach_roles(user, role_ids)
      ids = Array(role_ids).map(&:to_i).reject(&:zero?)
      user.roles = Role.where(id: ids)
    end
  end
end
