# frozen_string_literal: true

module Admin
  # 后台鉴权会话（先不管验权：仅做身份识别与会话，授权四期接 ActionPolicy）。
  # 走 admin 命名空间 → 自动套 admin layout / Inertia 栈，与前台隔离。
  class SessionsController < InertiaController
    # 登录页
    def new
      return redirect_to(admin_root_path) if logged_in?
      render inertia: "admin/login/index"
    end

    # 注册页
    def register_page
      return redirect_to(admin_root_path) if logged_in?
      render inertia: "admin/register/index"
    end

    # 发送验证码（手机/邮箱）。普通 XHR（前端 fetch 带 CSRF），返回 JSON。
    def send_code
      receiver = params[:receiver].to_s.strip
      channel = params[:channel].to_s.strip
      purpose = params[:purpose].to_s.strip.presence || "login"

      unless valid_receiver?(receiver, channel)
        return render(json: { error: "账号格式不正确" }, status: :unprocessable_entity)
      end

      begin
        vc = VerificationCode.generate!(receiver: receiver, channel: channel, purpose: purpose)
        SmsService.send_code(receiver: receiver, code: vc.code, purpose: purpose)
        # 开发期把码一并返回，方便前端联调；生产环境应删除 dev_code。
        render json: { ok: true, dev_code: vc.code }
      rescue VerificationCode::RateLimitError => e
        render json: { error: e.message }, status: :too_many_requests
      end
    end

    # 登录入口：按 login_type 分流（sms=手机验证码 / 其余=密码）。
    def create
      if params[:login_type].to_s == "sms"
        login_by_sms
      else
        login_by_password
      end
    end

    # 注册（手机为主）
    def register
      phone = params[:phone].to_s.strip
      code = params[:code].to_s.strip
      password = params[:password].to_s
      username = params[:username].to_s.strip
      email = params[:email].to_s.strip.presence

      unless phone.match?(/\A1[3-9]\d{9}\z/)
        return render(inertia: "admin/register/index", props: { error: "手机号格式不正确" })
      end
      if User.exists?(phone: phone)
        return render(inertia: "admin/register/index", props: { error: "该手机号已注册" })
      end
      unless password.length >= 6
        return render(inertia: "admin/register/index", props: { error: "密码至少 6 位" })
      end

      vc = VerificationCode.where(receiver: phone, channel: "sms", purpose: "register", used_at: nil)
                           .where("expires_at > ?", Time.current).order(created_at: :desc).first
      unless vc && vc.verify?(code)
        return render(inertia: "admin/register/index", props: { error: "验证码错误或已失效" })
      end

      user = User.new(
        phone: phone,
        username: username.presence || "m#{phone}",
        email: email,
        password: password,
        status: :enabled
      )
      if user.save
        log_in(user)
        redirect_to admin_root_path
      else
        render inertia: "admin/register/index", props: { error: user.errors.full_messages.join("；") }
      end
    end

    # 退出
    def destroy
      reset_session
      redirect_to admin_login_path
    end

    private

    def login_by_password
      account = params[:account].to_s.strip
      password = params[:password].to_s
      user = User.find_for_login(account)
      if user&.authenticate(password)
        return render(inertia: "admin/login/index", props: { error: "账号已被禁用" }) if user.disabled?
        log_in(user)
        redirect_to admin_root_path
      else
        render inertia: "admin/login/index", props: { error: "账号或密码错误" }
      end
    end

    def login_by_sms
      phone = params[:phone].to_s.strip
      code = params[:code].to_s.strip
      unless phone.match?(/\A1[3-9]\d{9}\z/)
        return render(inertia: "admin/login/index", props: { error: "手机号格式不正确" })
      end

      vc = VerificationCode.where(receiver: phone, channel: "sms", purpose: "login", used_at: nil)
                           .where("expires_at > ?", Time.current).order(created_at: :desc).first
      unless vc && vc.verify?(code)
        return render(inertia: "admin/login/index", props: { error: "验证码错误或已失效" })
      end

      # 首次手机验证码登录 → 自动建号（无密码，仅验证码登录；之后可设密码）。
      user = User.find_by(phone: phone)
      unless user
        uname = "m#{phone}"
        uname = "m#{phone}_#{SecureRandom.hex(2)}" while User.exists?(username: uname)
        user = User.create!(username: uname, phone: phone, status: :enabled)
      end
      return render(inertia: "admin/login/index", props: { error: "账号已被禁用" }) if user.disabled?

      log_in(user)
      redirect_to admin_root_path
    end

    def log_in(user)
      reset_session # 防 session fixation
      session[:user_id] = user.id
      user.update_columns(last_login_at: Time.current, login_ip: request.remote_ip)
    end

    def valid_receiver?(receiver, channel)
      return receiver.match?(/\A1[3-9]\d{9}\z/) if channel == "sms"
      return receiver.match?(URI::MailTo::EMAIL_REGEXP) if channel == "email"
      false
    end
  end
end
