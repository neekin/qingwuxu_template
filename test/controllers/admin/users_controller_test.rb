# frozen_string_literal: true

require "test_helper"

module Admin
  # 用户管理写路径三态测试（超管 success / 无权限 forbidden / 未登录 redirect）。
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @super = User.create!(
        username: "uc_super_#{SecureRandom.hex(3)}",
        phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123",
        super_admin: true
      )
      @guest_role = Role.create!(name: "访客", code: "guest_#{SecureRandom.hex(3)}", status: :enabled)
      @guest = User.create!(
        username: "uc_guest_#{SecureRandom.hex(3)}",
        phone: "136#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123"
      )
      @guest.roles << @guest_role
      @target = User.create!(
        username: "uc_target_#{SecureRandom.hex(3)}",
        phone: "137#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123"
      )
    end

    test "未登录访问 users 跳登录" do
      get admin_users_path
      assert_redirected_to admin_login_path
    end

    test "超管 GET index 放行" do
      login_as(@super)
      get admin_users_path
      assert_response :success
    end

    test "无权限用户 GET index 被拦(403)" do
      login_as(@guest)
      get admin_users_path
      assert_response :forbidden
    end

    test "超管 POST create 新建用户成功" do
      login_as(@super)
      assert_difference -> { User.count }, 1 do
        post admin_users_path, params: {
          username: "new_user_#{SecureRandom.hex(3)}",
          phone: "138#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
          password: "secret123",
          status: "enabled"
        }, headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_users_path
    end

    test "超管 PUT update 编辑用户（密码留空不改）成功" do
      login_as(@super)
      old_digest = @target.password_digest
      put admin_user_path(@target), params: {
        username: @target.username,
        phone: @target.phone,
        password: "",
        status: "disabled"
      }, headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_users_path
      @target.reload
      assert_equal "disabled", @target.status
      assert_equal old_digest, @target.password_digest
    end

    test "超管 DELETE destroy 删除普通用户成功" do
      login_as(@super)
      assert_difference -> { User.count }, -1 do
        delete admin_user_path(@target), headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_users_path
    end

    test "禁止删除自己（422）" do
      login_as(@super)
      delete admin_user_path(@super), headers: { "X-CSRF-Token" => csrf_token }
      assert_response :unprocessable_entity
    end

    test "禁止删除最后一个 super_admin（422）" do
      login_as(@super)
      delete admin_user_path(@super), headers: { "X-CSRF-Token" => csrf_token }
      assert_response :unprocessable_entity
      assert User.exists?(@super.id)
    end
  end
end
