# frozen_string_literal: true

require "test_helper"

module Admin
  # 验证 InertiaExampleController 收归 Admin::BaseController 后同样受鉴权红线约束。
  class InertiaExampleControllerTest < ActionDispatch::IntegrationTest
    setup do
      @super = User.create!(
        username: "super_#{SecureRandom.hex(3)}",
        phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, "0")}",
        password: "secret123",
        super_admin: true
      )
      @guest_role = Role.create!(name: "访客", code: "guest_#{SecureRandom.hex(3)}")
      @guest = User.create!(
        username: "guest_#{SecureRandom.hex(3)}",
        phone: "136#{SecureRandom.rand(10**8).to_s.rjust(8, "0")}",
        password: "secret123"
      )
      @guest.roles << @guest_role
    end

    test "未登录访问 inertia-example 跳登录" do
      get admin_inertia_example_path
      assert_redirected_to admin_login_path
    end

    test "超管访问 inertia-example 放行" do
      login_as(@super)
      get admin_inertia_example_path
      assert_response :success
    end

    test "无对应权限的已登录用户访问 inertia-example 被拦(403)" do
      login_as(@guest)
      get admin_inertia_example_path
      assert_response :forbidden
    end
  end
end
