# frozen_string_literal: true

require "test_helper"

module Admin
  # 个人中心三态测试（自服务：登录态即可，统一按 user:profile:view 判定）。
  class ProfilesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @super = User.create!(
        username: "pc_super_#{SecureRandom.hex(3)}",
        phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123",
        super_admin: true
      )
    end

    test "未登录访问 profile 跳登录" do
      get admin_profile_path
      assert_redirected_to admin_login_path
    end

    test "登录用户 GET profile 放行" do
      login_as(@super)
      get admin_profile_path
      assert_response :success
    end

    test "登录用户 PUT update 更新昵称成功" do
      login_as(@super)
      new_nick = "昵称_#{SecureRandom.hex(3)}"
      put admin_profile_path, params: { nickname: new_nick }, headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_profile_path
      @super.reload
      assert_equal new_nick, @super.nickname
    end

    test "登录用户 PUT change_password 原密码正确改密成功" do
      login_as(@super)
      put change_password_admin_profile_path,
          params: { old_password: "secret123", new_password: "newsecret1" },
          headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_profile_path
      @super.reload
      assert @super.authenticate("newsecret1")
    end

    test "原密码错误改密被拦截(422)" do
      login_as(@super)
      put change_password_admin_profile_path,
          params: { old_password: "wrongpwd", new_password: "newsecret1" },
          headers: { "X-CSRF-Token" => csrf_token }
      assert_response :unprocessable_entity
      @super.reload
      assert @super.authenticate("secret123")
    end
  end
end
