# frozen_string_literal: true

require "test_helper"

class PermissionTest < ActiveSupport::TestCase
  test "code 唯一" do
    Permission.create!(name: "权限A", code: "perm_unique_1")
    assert Permission.new(name: "权限B", code: "perm_unique_1").invalid?
  end

  test "name 必填" do
    assert Permission.new(code: "perm_no_name_#{SecureRandom.hex(3)}").invalid?
  end
end
