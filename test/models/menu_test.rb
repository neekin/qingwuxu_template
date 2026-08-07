# frozen_string_literal: true

require "test_helper"

class MenuTest < ActiveSupport::TestCase
  test "父子菜单关联" do
    parent = Menu.create!(name: "系统管理目录", menu_type: :catalog)
    child = Menu.create!(name: "用户管理菜单", menu_type: :menu, parent_id: parent.id)
    assert_equal parent, child.parent
    assert_includes parent.children, child
  end

  test "默认菜单类型与状态" do
    menu = Menu.create!(name: "默认菜单#{SecureRandom.hex(3)}", menu_type: :menu)
    assert menu.menu?
    assert menu.visible?
  end
end
