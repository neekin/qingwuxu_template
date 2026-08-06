# frozen_string_literal: true

require "bcrypt"

# 用户（中国人习惯：手机号为主标识；支持 用户名/邮箱/手机 三种登录）。
# 手写 bcrypt 封装而非 has_secure_password，以允许「无密码账户」
# （手机验证码注册 / 首次验证码登录自动建号，仅验证码登录，之后可设密码）。
class User < ApplicationRecord
  # ---- 密码（bcrypt）----
  # 虚拟属性 password：赋值即按 bcrypt 计算 digest；传入空值则不改动旧 digest。
  def password=(raw)
    @raw_password = raw
    self.password_digest = BCrypt::Password.create(raw) if raw.present?
  end

  # 校验明文密码，无密码账户（digest 为空）一律返回 false。
  def authenticate(plain)
    return false if password_digest.blank?
    BCrypt::Password.new(password_digest).is_password?(plain)
  end

  def has_password?
    password_digest.present?
  end

  # ---- 状态（RBAC 约定：0=禁用 1=启用）----
  enum :status, { disabled: 0, enabled: 1 }, default: :enabled

  # ---- 校验 ----
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :phone, presence: true, uniqueness: true,
            format: { with: /\A1[3-9]\d{9}\z/, message: "手机号格式不正确" }
  validates :email, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validate :password_length

  # ---- 查询 ----
  # 用户名 / 邮箱 / 手机 任一匹配即返回（三种密码登录方式共用）。
  def self.find_for_login(login)
    return nil if login.blank?
    where(username: login).or(where(email: login)).or(where(phone: login)).first
  end

  def display_name
    username.presence || phone.presence || email.presence || "用户#{id}"
  end

  private

  def password_length
    return if @raw_password.blank?
    errors.add(:password, "至少 6 位") if @raw_password.length < 6
  end
end
