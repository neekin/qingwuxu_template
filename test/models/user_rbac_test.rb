# frozen_string_literal: true

require "test_helper"

class UserRbacTest < ActiveSupport::TestCase
  setup do
    @super = User.create!(username: "super_#{SecureRandom.hex(3)}",
                          phone: "138#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
                          password: "secret123", super_admin: true)
    @normal = User.create!(username: "normal_#{SecureRandom.hex(3)}",
                           phone: "137#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
                           password: "secret123")
    @perm = Permission.create!(name: "用户管理", code: "system:user:list")
    @role = Role.create!(name: "普通角色", code: "normal_#{SecureRandom.hex(3)}")
    @role.permissions << @perm
    @normal.roles << @role
  end

  test "super_admin 直通所有权限" do
    assert @super.has_permission?("system:user:list")
    assert @super.has_permission?("anything:not:exist")
  end

  test "普通用户按角色权限判定" do
    assert @normal.has_permission?("system:user:list")
    refute @normal.has_permission?("system:role:list")
  end

  test "permission_codes 集合" do
    assert_includes @normal.permission_codes, "system:user:list"
    refute_includes @normal.permission_codes, "system:role:list"
  end
end
