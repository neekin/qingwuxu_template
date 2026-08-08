# frozen_string_literal: true

require "test_helper"

# 数据权限验证：不同 data_scope 的普通用户（持有 system:user:list）
# 经 policy_scope(User.all, with: UserPolicy) 返回不同集合。
# - all：全部
# - dept：仅同部门
# - dept_and_child：本部门 + 下级子树
# - self：仅自己
# 同时校验 IDOR 防线不被破坏：无 system:user:list 权限返回空集。
class DataScopeTest < ActiveSupport::TestCase
  setup do
    # 部门树：dept_rd(根) -> dept_rd1(子)；dept_other(另一根)
    @dept_rd = Department.create!(code: "RD", name: "研发部")
    @dept_rd1 = Department.create!(code: "RD1", name: "研发一组", parent: @dept_rd)
    @dept_other = Department.create!(code: "OTH", name: "其他部")

    # 权限点 + 角色（持有 system:user:list 与 system:role:list），仅绑定到「作为当前用户」的几个账号。
    perm = Permission.create!(code: "system:user:list", name: "用户列表")
    perm_role = Permission.create!(code: "system:role:list", name: "角色列表")
    @role = Role.create!(name: "部门管理员", code: "dept_admin")
    RolePermission.create!(role: @role, permission: perm)
    RolePermission.create!(role: @role, permission: perm_role)

    u = ->(key, dept, scope) do
      User.create!(
        username: "#{key}_#{SecureRandom.hex(3)}",
        phone: "137#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123",
        department: dept,
        data_scope: scope
      )
    end
    @a = u.call("a", @dept_rd, :dept)
    @b = u.call("b", @dept_rd, :dept)
    @c = u.call("c", @dept_rd, :dept_and_child)
    @d = u.call("d", @dept_rd, :self)
    @e = u.call("e", @dept_rd1, :dept)
    @f = u.call("f", @dept_other, :dept)
    # 当前用户需持 system:user:list 才不被 scope 拦截为空集
    [@a, @c, @d].each { |x| UserRole.create!(user: x, role: @role) }
  end

  def scoped(user)
    UserPolicy.new(User, user: user).apply_scope(User.all, type: :active_record_relation)
  end

  test "data_scope=dept 仅返回同部门用户" do
    # a/b/c/d 均属 dept_rd（d 仅自身可见，但部门过滤按 department_id，不看出自身 data_scope）
    assert_equal [@a.id, @b.id, @c.id, @d.id].sort, scoped(@a).pluck(:id).sort
  end

  test "data_scope=dept_and_child 返回本部门及下级子树" do
    # 本部门 dept_rd(a/b/c/d) + 下级 dept_rd1(e)
    assert_equal [@a.id, @b.id, @c.id, @d.id, @e.id].sort, scoped(@c).pluck(:id).sort
  end

  test "data_scope=self 仅返回自己" do
    assert_equal [@d.id], scoped(@d).pluck(:id)
  end

  test "无 system:user:list 权限返回空集（IDOR 防线保持）" do
    # @e 未绑定含 system:user:list 的角色
    assert_equal 0, scoped(@e).count
  end

  test "无 department_id 的资源(如 Role)不按数据权限部门过滤" do
    # @a 持有 system:role:list，但 Role 无 department_id 列 → 返回全部，不被 dept 范围收窄
    assert_equal Role.count,
                 RolePolicy.new(Role, user: @a).apply_scope(Role.all, type: :active_record_relation).count
  end
end
