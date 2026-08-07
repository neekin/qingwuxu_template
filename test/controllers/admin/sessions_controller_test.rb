# frozen_string_literal: true

require "test_helper"

module Admin
  # 验证 P0 安全修复：dev_code 守卫 / CSRF 强制 / 禁用用户会话拦截
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    # 修复 1：非 development 环境（含 test）send_code 绝不回真实验证码
    test "send_code 不泄露验证码（非 development 环境）" do
      get admin_login_path
      post admin_login_send_code_path,
           params: { receiver: "13800000000", channel: "sms", purpose: "login" },
           headers: { "X-CSRF-Token" => csrf_token }
      assert_response :success
      body = response.parsed_body
      assert_equal true, body["ok"]
      assert_not_includes body, "dev_code", "验证码不得出现在非 development 环境的响应中"
    end

    # 修复 2：裸 POST（无 CSRF token）必须被拒绝(422)
    test "裸 POST send_code 无 CSRF token 被拒绝(422)" do
      post admin_login_send_code_path,
           params: { receiver: "13800000000", channel: "sms", purpose: "login" }
      assert_response :unprocessable_entity
    end

    # 修复 4：已登录用户被禁用后，其已有会话被拦截（视为未登录，跳登录）
    test "被禁用用户的已有会话被拒绝(跳登录)" do
      user = User.create!(
        username: "dis_#{SecureRandom.hex(3)}",
        phone: "137#{SecureRandom.rand(10**8).to_s.rjust(8, "0")}",
        password: "secret123",
        super_admin: true
      )
      login_as(user)
      # 登录成功后由管理员禁用该账号，模拟「登录期间被禁用」
      user.update!(status: :disabled)
      get admin_dashboard_path
      assert_redirected_to admin_login_path
    end
  end
end
