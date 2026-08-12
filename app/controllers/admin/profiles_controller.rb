# frozen_string_literal: true

module Admin
  # 个人中心（真实 CRUD：资料更新 + 改密码）。
  # 自服务：登录态即可，统一按 user:profile:view 权限点判定（不判 system:* 写权限）。
  # 成功 → redirect_to profile；校验失败 → 422 + errors。
  class ProfilesController < BaseController
    # GET /admin/profile -> 渲染个人中心页（下发当前用户资料 + 头像 URL）
    def show
      authorize! nil, to: :view?, with: ProfilePolicy
      render inertia: "admin/profile/index", props: profile_props
    end

    # PUT /admin/profile -> 更新昵称/邮箱/手机/头像
    def update
      authorize! nil, to: :update?, with: ProfilePolicy
      if current_user.update(profile_params)
        redirect_to admin_profile_path
      else
        render inertia: "admin/profile/index",
               props: profile_props.merge(errors: current_user.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    # PUT /admin/profile/change_password -> 校验原密码后改密码
    def change_password
      authorize! nil, to: :change_password?, with: ProfilePolicy
      old_pwd = params[:old_password].to_s
      new_pwd = params[:new_password].to_s
      unless current_user.authenticate(old_pwd)
        render inertia: "admin/profile/index",
               props: profile_props.merge(errors: ["原密码不正确"]),
               status: :unprocessable_entity
        return
      end
      if new_pwd.length < 6
        render inertia: "admin/profile/index",
               props: profile_props.merge(errors: ["新密码至少 6 位"]),
               status: :unprocessable_entity
        return
      end
      current_user.password = new_pwd
      current_user.save!
      redirect_to admin_profile_path
    end

    private

    def profile_props
      u = current_user
      {
        user: {
          id: u.id,
          username: u.username,
          nickname: u.nickname,
          email: u.email,
          phone: u.phone,
          dept: u.department&.name,
          role: u.roles.pluck(:name).join("、"),
          avatar_url: u.avatar.attached? ? Rails.application.routes.url_helpers.rails_blob_path(u.avatar.blob, disposition: :inline, only_path: true) : nil,
          created_at: u.created_at.strftime("%Y-%m-%d %H:%M")
        }
      }
    end

    # 前端发裸 values；avatar 为上传文件时由 Active Storage 附件写入接管。
    def profile_params
      params.permit(:nickname, :email, :phone, :avatar)
    end
  end
end
