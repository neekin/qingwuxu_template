# frozen_string_literal: true

require "test_helper"

module Admin
  # 验证 ActionPolicy 验权范式：超管直通、无权限用户被拦(403)、未登录跳登录
  class PagesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @super = User.create!(
        username: "super_#{SecureRandom.hex(3)}",
        phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123",
        super_admin: true
      )
      @guest_role = Role.create!(name: "访客", code: "guest_#{SecureRandom.hex(3)}")
      @guest = User.create!(
        username: "guest_#{SecureRandom.hex(3)}",
        phone: "136#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123"
      )
      @guest.roles << @guest_role
    end

    test "超管访问用户页放行" do
      login_as(@super)
      get admin_users_path
      assert_response :success
    end

    test "用户列表注入真实查询数据" do
      login_as(@super)
      get admin_users_path
      # Inertia 将 props 序列化进页面，真实查询出的当前用户名应出现在响应中
      assert_match @super.username, response.body
    end

    test "无权限用户访问用户页被拦(403)" do
      login_as(@guest)
      get admin_users_path
      assert_response :forbidden
    end

    test "未登录访问用户页跳登录" do
      get admin_users_path
      assert_redirected_to admin_login_path
    end

    # 修复 3：此前未过授权的 6 个后台页面动作，必须每个都过 authorize!
    #         未登录 → 跳登录；已登录但无权限 → 403（ActionPolicy::Unauthorized 兜底）。
    PAGE_PATHS = {
      dashboard: :admin_dashboard_path,
      menus: :admin_menus_path,
      departments: :admin_departments_path,
      operation_logs: :admin_operation_logs_path,
      login_logs: :admin_login_logs_path,
      profile: :admin_profile_path
    }.freeze

    PAGE_PATHS.each do |_name, path_helper|
      test "未登录访问 #{path_helper} 跳登录" do
        get send(path_helper)
        assert_redirected_to admin_login_path
      end

      test "无权限用户访问 #{path_helper} 被拦(403)" do
        login_as(@guest)
        get send(path_helper)
        assert_response :forbidden
      end

      test "超管访问 #{path_helper} 放行" do
        login_as(@super)
        get send(path_helper)
        assert_response :success
      end
    end
  end
end
