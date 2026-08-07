class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # CSRF 防护：所有非 GET 请求必须携带合法 X-CSRF-Token，否则抛 InvalidAuthenticityToken(422)。
  # Inertia 前端默认在 POST 头带 token，故开启是安全的；禁止为绕过而 disable。
  protect_from_forgery with: :exception

  helper_method :current_user, :logged_in?

  # 阶段 1：ActionPolicy 验权失败统一兜底（无权限 → 403，前端据此处理）
  rescue_from ActionPolicy::Unauthorized, with: :deny_access

  private

  def deny_access
    head :forbidden
  end

  def current_user
    return @current_user if instance_variable_defined?(:@current_user)
    @current_user = resolve_current_user
  end

  # 被禁用(disabled)用户视为未登录：清空其会话并返回 nil，使 require_login 将其弹走。
  def resolve_current_user
    return nil unless session[:user_id]
    user = User.find_by(id: session[:user_id])
    return user unless user&.disabled?
    session.delete(:user_id)
    nil
  end

  def logged_in?
    current_user.present?
  end

  # 验权前置：未登录（或被禁用拦截）一律跳登录页。
  def require_login
    return if logged_in?
    redirect_to admin_login_path
  end
end
