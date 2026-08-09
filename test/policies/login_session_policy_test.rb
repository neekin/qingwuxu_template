# frozen_string_literal: true

require "test_helper"

# 在线用户授权：超管直通、持权限放行、无权限被 IDOR 防线拦截。
class LoginSessionPolicyTest < ActiveSupport::TestCase
  setup do
    @super = User.create!(
      username: "op_super_#{SecureRandom.hex(3)}",
      phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
      password: "secret123",
      super_admin: true
    )
    perm_list = Permission.create!(code: "system:online:list", name: "在线用户")
    perm_force = Permission.create!(code: "system:online:force", name: "强制下线")
    @role = Role.create!(name: "监控员", code: "monitor_#{SecureRandom.hex(3)}")
    RolePermission.create!(role: @role, permission: perm_list)
    RolePermission.create!(role: @role, permission: perm_force)
    @viewer = User.create!(
      username: "op_viewer_#{SecureRandom.hex(3)}",
      phone: "136#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
      password: "secret123"
    )
    @viewer.roles << @role
    @no_perm = User.create!(
      username: "op_none_#{SecureRandom.hex(3)}",
      phone: "137#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
      password: "secret123"
    )
  end

  test "超管直通：index?/destroy? 均放行" do
    assert LoginSessionPolicy.new(LoginSession, user: @super).index?
    assert LoginSessionPolicy.new(LoginSession, user: @super).destroy?
  end

  test "持权限用户 index?/destroy? 放行" do
    assert LoginSessionPolicy.new(LoginSession, user: @viewer).index?
    assert LoginSessionPolicy.new(LoginSession, user: @viewer).destroy?
  end

  test "无权限用户 index? 拒绝（IDOR 防线）" do
    refute LoginSessionPolicy.new(LoginSession, user: @no_perm).index?
  end

  test "policy_scope：超管返回全部，无权限返回空集" do
    LoginSession.create!(user: @viewer, last_seen_at: Time.current)
    assert_equal LoginSession.count,
                 LoginSessionPolicy.new(LoginSession, user: @super)
                   .apply_scope(LoginSession.all, type: :active_record_relation).count
    assert_equal 0,
                 LoginSessionPolicy.new(LoginSession, user: @no_perm)
                   .apply_scope(LoginSession.all, type: :active_record_relation).count
  end
end
