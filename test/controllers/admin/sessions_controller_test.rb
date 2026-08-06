require "test_helper"

module Admin
  # 覆盖三种登录方式 + 验证码发送 + 注册（手机为主）。
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = User.create!(
        username: "tester",
        email: "tester@example.com",
        phone: "13900000001",
        password: "secret123",
        status: :enabled
      )
    end

    test "用户名密码登录成功" do
      post admin_login_path, params: { login_type: "password", account: "tester", password: "secret123" }
      assert_redirected_to admin_root_path
      assert_equal @user.id, session[:user_id]
    end

    test "邮箱密码登录成功" do
      post admin_login_path, params: { login_type: "password", account: "tester@example.com", password: "secret123" }
      assert_redirected_to admin_root_path
    end

    test "手机密码登录成功" do
      post admin_login_path, params: { login_type: "password", account: "13900000001", password: "secret123" }
      assert_redirected_to admin_root_path
    end

    test "密码错误登录失败" do
      post admin_login_path, params: { login_type: "password", account: "tester", password: "wrong" }
      assert_response :success
    end

    test "手机验证码登录成功（含首次自动建号）" do
      vc = VerificationCode.generate!(receiver: "13900000002", channel: "sms", purpose: "login")
      assert_difference -> { User.count }, 1 do
        post admin_login_path, params: { login_type: "sms", phone: "13900000002", code: vc.code }
      end
      assert_redirected_to admin_root_path
      assert User.find_by(phone: "13900000002")
    end

    test "手机验证码错误登录失败" do
      VerificationCode.generate!(receiver: "13900000003", channel: "sms", purpose: "login")
      post admin_login_path, params: { login_type: "sms", phone: "13900000003", code: "000000" }
      assert_response :success
    end

    test "send_code 生成验证码" do
      post admin_login_send_code_path, params: { receiver: "13900000004", channel: "sms", purpose: "login" }, as: :json
      assert_response :success
      body = JSON.parse(response.body)
      assert body["ok"]
      assert_equal 6, body["dev_code"].length
      assert VerificationCode.exists?(receiver: "13900000004", channel: "sms")
    end

    test "注册成功建号" do
      vc = VerificationCode.generate!(receiver: "13900000005", channel: "sms", purpose: "register")
      post admin_register_path, params: {
        phone: "13900000005", code: vc.code, password: "newpass123",
        username: "newbie", email: "newbie@example.com"
      }
      assert_redirected_to admin_root_path
      u = User.find_by(phone: "13900000005")
      assert u
      assert u.authenticate("newpass123")
    end

    test "重复手机号注册被拒" do
      VerificationCode.generate!(receiver: "13900000001", channel: "sms", purpose: "register")
      post admin_register_path, params: { phone: "13900000001", code: "000000", password: "abcdef" }
      assert_response :success
    end
  end
end
