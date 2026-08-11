# frozen_string_literal: true

require "test_helper"

module Admin
  # 角色管理写路径三态测试（超管 success / 无权限 forbidden / 未登录 redirect）。
  class RolesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @super = User.create!(
        username: "rc_super_#{SecureRandom.hex(3)}",
        phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123",
        super_admin: true
      )
      @guest_role = Role.create!(name: "访客", code: "guest_#{SecureRandom.hex(3)}", status: :enabled)
      @guest = User.create!(
        username: "rc_guest_#{SecureRandom.hex(3)}",
        phone: "136#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123"
      )
      @guest.roles << @guest_role
      @perm = Permission.create!(code: "test:perm_#{SecureRandom.hex(3)}", name: "测试权限点")
      @target = Role.create!(
        name: "待删角色",
        code: "todelete_#{SecureRandom.hex(3)}",
        status: :enabled
      )
    end

    test "未登录访问 roles 跳登录" do
      get admin_roles_path
      assert_redirected_to admin_login_path
    end

    test "超管 GET index 放行" do
      login_as(@super)
      get admin_roles_path
      assert_response :success
    end

    test "无权限用户 GET index 被拦(403)" do
      login_as(@guest)
      get admin_roles_path
      assert_response :forbidden
    end

    test "超管 POST create 新建角色成功" do
      login_as(@super)
      assert_difference -> { Role.count }, 1 do
        post admin_roles_path, params: {
          name: "新角色_#{SecureRandom.hex(3)}",
          code: "newrole_#{SecureRandom.hex(3)}",
          status: "enabled",
          description: "由测试创建",
          permission_ids: [@perm.id]
        }, headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_roles_path
    end

    test "超管 PUT update 编辑角色成功" do
      login_as(@super)
      put admin_role_path(@target), params: {
        name: "改名角色",
        code: @target.code,
        status: "disabled",
        description: "已编辑",
        permission_ids: [@perm.id]
      }, headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_roles_path
      @target.reload
      assert_equal "改名角色", @target.name
      assert_equal "disabled", @target.status
      assert_equal [@perm.id], @target.permission_ids
    end

    test "超管 DELETE destroy 删除普通角色成功" do
      login_as(@super)
      assert_difference -> { Role.count }, -1 do
        delete admin_role_path(@target), headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_roles_path
    end

    test "禁止删除 super_admin 角色（422）" do
      login_as(@super)
      locked = Role.create!(name: "超级管理员", code: "super_admin", status: :enabled)
      delete admin_role_path(locked), headers: { "X-CSRF-Token" => csrf_token }
      assert_response :unprocessable_entity
      assert Role.exists?(locked.id)
    end
  end
end
