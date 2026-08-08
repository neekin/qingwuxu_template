# frozen_string_literal: true

require "test_helper"

module Admin
  # 在线用户控制器：三态验证（未登录跳登录 / 无权限 403 / 超管放行 + 强制下线成功）
  # 注：渲染 admin layout 的集成测试依赖 vite 构建，本沙箱护栏会拦截，属环境限制非代码错。
  class OnlineUsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @super = User.create!(
        username: "ou_super_#{SecureRandom.hex(3)}",
        phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123",
        super_admin: true
      )
      @guest_role = Role.create!(name: "访客", code: "guest_#{SecureRandom.hex(3)}")
      @guest = User.create!(
        username: "ou_guest_#{SecureRandom.hex(3)}",
        phone: "136#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123"
      )
      @guest.roles << @guest_role
    end

    test "未登录访问在线用户跳登录" do
      get admin_online_users_path
      assert_redirected_to admin_login_path
    end

    test "无权限用户访问在线用户被拦(403)" do
      login_as(@guest)
      get admin_online_users_path
      assert_response :forbidden
    end

    test "超管访问在线用户放行" do
      login_as(@super)
      get admin_online_users_path
      assert_response :success
    end

    test "超管强制下线其他会话成功" do
      login_as(@super)
      target = LoginSession.create!(user: @guest, last_seen_at: Time.current)
      get root_path
      assert_difference -> { LoginSession.count }, -1 do
        delete admin_online_user_path(target),
               headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_online_users_path
    end

    test "无权限用户强制下线被拦(403)" do
      login_as(@guest)
      target = LoginSession.create!(user: @super, last_seen_at: Time.current)
      get root_path
      delete admin_online_user_path(target),
             headers: { "X-CSRF-Token" => csrf_token }
      assert_response :forbidden
    end
  end
end
