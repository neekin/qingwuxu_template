# frozen_string_literal: true

require "test_helper"

# CI 红线：自动发现并强制 Admin 命名空间控制器的合规约定。
# - 除认证端点 Admin::SessionsController 与基类 Admin::BaseController 外，
#   每个 Admin 控制器都必须 < Admin::BaseController（服务端为唯一真相、自动套 admin layout / Inertia 栈）。
# - 且其必须有授权路径：自身定义了 authorize! / allowed_to? 调用，
#   或其某个祖先声明了强制授权(authorize)的 before_action。
# 未来新增「继承 BaseController 却无任何 authorize 路径」的控制器会在此 CI 红。
class AdminControllerConventionTest < ActionDispatch::IntegrationTest
  # 认证端点（登录/注册/验证码），正确无需 authorize，豁免。
  EXEMPT_CONTROLLERS = [Admin::SessionsController].freeze
  # 基类自身是约定锚点，不要求它继承自己。
  BASE_CONTROLLER = Admin::BaseController

  setup do
    # 确保全部控制器类已加载，才能枚举 descendants。
    unless self.class.eager_loaded
      Rails.application.eager_load! unless Rails.application.config.eager_load
      self.class.eager_loaded = true
    end
  end

  def self.eager_loaded
    @eager_loaded
  end

  def self.eager_loaded=(v)
    @eager_loaded = v
  end

  test "所有 Admin 控制器(豁免除外)都继承 Admin::BaseController" do
    subject_controllers.each do |klass|
      assert klass.ancestors.include?(BASE_CONTROLLER),
        "控制器 #{klass} 必须继承 Admin::BaseController（服务端为唯一真相 / 自动套 admin 栈）"
    end
  end

  test "继承 BaseController 的 Admin 控制器必须有授权路径" do
    subject_controllers.each do |klass|
      assert klass.ancestors.include?(BASE_CONTROLLER),
        "#{klass} 必须 < Admin::BaseController"

      assert authorization_present?(klass),
        "控制器 #{klass} 继承 Admin::BaseController 但无任何 authorize 路径：" \
        "需自身定义 authorize! / allowed_to?，或祖先有强制授权(authorize)的 before_action"
    end
  end

  private

  # 受检集合：ApplicationController 的所有 Admin:: 命名空间后代，排除豁免项与基类自身。
  def subject_controllers
    ApplicationController.descendants.select do |klass|
      klass.name&.start_with?("Admin::") &&
        !EXEMPT_CONTROLLERS.include?(klass) &&
        klass != BASE_CONTROLLER
    end
  end

  # 是否存在授权路径：祖先链有 authorize 的 before_action，或自身源码含 authorize! / allowed_to?。
  def authorization_present?(klass)
    ancestor_authorize_before_action?(klass) || source_uses_authorize?(klass)
  end

  def ancestor_authorize_before_action?(klass)
    klass.ancestors.each do |anc|
      next unless anc.respond_to?(:_process_action_callbacks)
      anc._process_action_callbacks.each do |cb|
        next unless cb.kind == :before
        filter = cb.respond_to?(:filter) ? cb.filter : cb.name
        return true if filter.to_s.match?(/authoriz/)
      end
    end
    false
  end

  # 检测控制器源码是否定义了 authorize! / allowed_to? 调用。
  # 注意：Zeitwerk 下 Object.const_source_location 会返回框架内部文件，不可靠；
  # 故按 Rails 命名约定由常量名推导真实源码路径（app/controllers 下）。
  def source_uses_authorize?(klass)
    file = controller_source_file(klass)
    return false unless file && File.exist?(file)
    File.read(file).match?(/\bauthorize!/) || File.read(file).match?(/\ballowed_to\?/)
  rescue StandardError
    false
  end

  def controller_source_file(klass)
    parts = klass.name.split("::").map(&:underscore)
    Rails.root.join("app/controllers", *parts).to_s + ".rb"
  end
end
