# frozen_string_literal: true

require "test_helper"

# IDOR 作用域防线验证：policy_scope 对超管返回全量、对无权限普通用户返回空集。
# 控制器侧用 policy_scope(User.all, with: UserPolicy)（别名，底层 authorized_scope + scope_for :active_record_relation）。
class IdorScopeTest < ActiveSupport::TestCase
  setup do
    @super = User.create!(
      username: "super_#{SecureRandom.hex(3)}",
      phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
      password: "secret123",
      super_admin: true
    )
    @guest_role = Role.create!(name: "访客", code: "guest_#{SecureRandom.hex(3)}")
    @guest = User.create!(
      username: "guest_#{SecureRandom.hex(3)}",
      phone: "136#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
      password: "secret123"
    )
    @guest.roles << @guest_role
  end

  test "policy_scope(User) 超管返回全量" do
    scoped = UserPolicy.new(User, user: @super).apply_scope(User.all, type: :active_record_relation)
    assert_equal User.count, scoped.count
  end

  test "policy_scope(User) 无权限普通用户返回空集" do
    scoped = UserPolicy.new(User, user: @guest).apply_scope(User.all, type: :active_record_relation)
    assert_equal 0, scoped.count
  end

  test "policy_scope(Role) 超管返回全量 / 无权限普通用户返回空集" do
    assert_equal Role.count,
                 RolePolicy.new(Role, user: @super).apply_scope(Role.all, type: :active_record_relation).count
    assert_equal 0,
                 RolePolicy.new(Role, user: @guest).apply_scope(Role.all, type: :active_record_relation).count
  end
end
