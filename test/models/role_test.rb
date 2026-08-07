# frozen_string_literal: true

require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "code 唯一" do
    Role.create!(name: "角色A", code: "role_unique_1")
    dup = Role.new(name: "角色B", code: "role_unique_1")
    assert dup.invalid?
  end

  test "默认启用" do
    role = Role.create!(name: "启用角色", code: "role_enabled_#{SecureRandom.hex(3)}")
    assert role.enabled?
  end

  test "关联用户与权限" do
    role = Role.create!(name: "关联角色", code: "role_rel_#{SecureRandom.hex(3)}")
    user = User.create!(username: "u_#{SecureRandom.hex(3)}",
                         phone: "139#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
                         password: "secret123")
    perm = Permission.create!(name: "权限", code: "perm_#{SecureRandom.hex(3)}")
    role.permissions << perm
    user.roles << role
    assert_includes role.permissions, perm
    assert_includes user.roles, role
  end
end
