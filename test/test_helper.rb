ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# 集成测试辅助：CSRF 防护开启后，所有非 GET 请求必须带合法 X-CSRF-Token。
# Inertia 前端默认带 token；测试侧从登录页 HTML 的 <meta name="csrf-token"> 取回并随请求发送。
class ActionDispatch::IntegrationTest
  # 从最近一次响应 HTML 中提取 CSRF token（admin layout 已渲染 csrf_meta_tags）。
  def csrf_token
    response.body[/name="csrf-token" content="([^"]+)"/, 1]
  end

  # 以密码方式登录（自动携带 CSRF token），模拟 Inertia 客户端行为。
  def login_as(user, password: "secret123")
    get admin_login_path
    post admin_login_path,
         params: { login_type: "password", account: user.username, password: password },
         headers: { "X-CSRF-Token" => csrf_token }
  end
end

