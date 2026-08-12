# frozen_string_literal: true

require "test_helper"

module Admin
  # 菜单管理写路径三态测试（超管 success / 无权限 forbidden / 未登录 redirect）。
  class MenusControllerTest < ActionDispatch::IntegrationTest
    setup do
      @super = User.create!(
        username: "mc_super_#{SecureRandom.hex(3)}",
        phone: "135#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123",
        super_admin: true
      )
      @guest_role = Role.create!(name: "访客", code: "guest_#{SecureRandom.hex(3)}", status: :enabled)
      @guest = User.create!(
        username: "mc_guest_#{SecureRandom.hex(3)}",
        phone: "136#{SecureRandom.rand(10**8).to_s.rjust(8, '0')}",
        password: "secret123"
      )
      @guest.roles << @guest_role
    end

    test "未登录访问 menus 跳登录" do
      get admin_menus_path
      assert_redirected_to admin_login_path
    end

    test "超管 GET index 放行" do
      login_as(@super)
      get admin_menus_path
      assert_response :success
    end

    test "无权限用户 GET index 被拦(403)" do
      login_as(@guest)
      get admin_menus_path
      assert_response :forbidden
    end

    test "超管 POST create 新建菜单成功" do
      login_as(@super)
      assert_difference -> { Menu.count }, 1 do
        post admin_menus_path, params: {
          name: "测试菜单_#{SecureRandom.hex(3)}",
          menu_type: "menu",
          route: "/admin/test",
          permission_code: "test:list",
          status: "visible",
          sort: 1
        }, headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_menus_path
    end

    test "超管 PUT update 编辑菜单成功" do
      login_as(@super)
      menu = Menu.create!(name: "up_#{SecureRandom.hex(3)}", menu_type: :menu, status: :visible)
      put admin_menu_path(menu), params: {
        name: menu.name,
        menu_type: "menu",
        status: "hidden"
      }, headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_menus_path
      menu.reload
      assert_equal "hidden", menu.status
    end

    test "超管 DELETE destroy 删除菜单成功" do
      login_as(@super)
      menu = Menu.create!(name: "del_#{SecureRandom.hex(3)}", menu_type: :menu, status: :visible)
      assert_difference -> { Menu.count }, -1 do
        delete admin_menu_path(menu), headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_menus_path
    end

    test "含子项的菜单删除被拦截(422)" do
      login_as(@super)
      parent = Menu.create!(name: "parent_#{SecureRandom.hex(3)}", menu_type: :catalog, status: :visible)
      Menu.create!(name: "child_#{SecureRandom.hex(3)}", menu_type: :menu, status: :visible, parent_id: parent.id)
      delete admin_menu_path(parent), headers: { "X-CSRF-Token" => csrf_token }
      assert_response :unprocessable_entity
      assert Menu.exists?(parent.id)
    end
  end
end
