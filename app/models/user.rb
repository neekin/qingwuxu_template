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

  # ---- 部门关联（P1 第二批：数据权限按 department_id 过滤）----
  belongs_to :department, optional: true

  # ---- 在线会话（P1 第一批末项：在线用户监控 + 强制下线）----
  has_many :login_sessions, dependent: :destroy

  # ---- 状态（RBAC 约定：0=禁用 1=启用）----
  enum :status, { disabled: 0, enabled: 1 }, default: :enabled

  # ---- 数据权限范围（0=全部 /1=自定义 /2=本部门 /3=本部门及下级 /4=仅自己）----
  # prefix: :data_scope 避免值名 all/self 与 ActiveRecord 类方法冲突（属性读取 data_scope 仍返回符号）。
  enum :data_scope, { all: 0, custom: 1, dept: 2, dept_and_child: 3, self: 4 }, default: :all, prefix: :data_scope

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

  # ---- RBAC 关联（阶段 0）----
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  # 是否拥有某权限点（RBAC 最小授权单元是 permission.code）。
  # 超管直通；其余按「角色 → 权限」聚合判定（预加载避免 N+1）。
  def has_permission?(code)
    return true if super_admin?
    roles.includes(:permissions).any? { |role| role.permissions.any? { |p| p.code == code.to_s } }
  end

  # 当前用户全部权限字符（用于动态菜单 / 接口鉴权）。
  def permission_codes
    return Permission.pluck(:code) if super_admin?
    roles.flat_map { |role| role.permissions.pluck(:code) }.uniq
  end

  private

  def password_length
    return if @raw_password.blank?
    errors.add(:password, "至少 6 位") if @raw_password.length < 6
  end
end
