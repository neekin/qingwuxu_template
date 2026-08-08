# frozen_string_literal: true

require "test_helper"

module Admin
  # 字典类型管理控制器：三态验证（未登录跳登录 / 无权限 403 / 超管放行 + 写路径成功失败）
  class DictionaryTypesControllerTest < ActionDispatch::IntegrationTest
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

    # ---- index 三态 ----
    test "未登录访问字典类型列表跳登录" do
      get admin_dictionary_types_path
      assert_redirected_to admin_login_path
    end

    test "无权限用户访问字典类型列表被拦(403)" do
      login_as(@guest)
      get admin_dictionary_types_path
      assert_response :forbidden
    end

    test "超管访问字典类型列表放行" do
      login_as(@super)
      get admin_dictionary_types_path
      assert_response :success
    end

    # ---- create 三态 ----
    test "未登录创建字典类型跳登录" do
      get root_path
      post admin_dictionary_types_path,
           params: { dictionary_type: { code: "t1", name: "测试" } },
           headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_login_path
    end

    test "无权限用户创建字典类型被拦(403)" do
      login_as(@guest)
      get root_path
      post admin_dictionary_types_path,
           params: { dictionary_type: { code: "t1", name: "测试" } },
           headers: { "X-CSRF-Token" => csrf_token }
      assert_response :forbidden
    end

    test "超管创建字典类型成功(重定向刷新列表)" do
      login_as(@super)
      get root_path
      assert_difference -> { DictionaryType.count }, 1 do
        post admin_dictionary_types_path,
             params: { dictionary_type: { code: "t1", name: "测试" } },
             headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_dictionary_types_path
    end

    test "超管创建字典类型带非法参数返回 422" do
      login_as(@super)
      get root_path
      assert_no_difference -> { DictionaryType.count } do
        post admin_dictionary_types_path,
             params: { dictionary_type: { code: "", name: "" } },
             headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_response :unprocessable_entity
    end

    # ---- update ----
    test "超管更新字典类型成功" do
      login_as(@super)
      type = DictionaryType.create!(code: "u1", name: "原")
      get root_path
      put admin_dictionary_type_path(type),
          params: { dictionary_type: { name: "改" } },
          headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_dictionary_types_path
      assert_equal "改", type.reload.name
    end

    test "超管更新字典类型带非法参数返回 422" do
      login_as(@super)
      type = DictionaryType.create!(code: "u2", name: "原")
      get root_path
      put admin_dictionary_type_path(type),
          params: { dictionary_type: { code: "" } },
          headers: { "X-CSRF-Token" => csrf_token }
      assert_response :unprocessable_entity
    end

    # ---- destroy ----
    test "超管删除字典类型成功" do
      login_as(@super)
      type = DictionaryType.create!(code: "d1", name: "删")
      get root_path
      assert_difference -> { DictionaryType.count }, -1 do
        delete admin_dictionary_type_path(type),
               headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_dictionary_types_path
    end

    test "无权限用户删除字典类型被拦(403)" do
      login_as(@guest)
      type = DictionaryType.create!(code: "d2", name: "删")
      get root_path
      delete admin_dictionary_type_path(type),
             headers: { "X-CSRF-Token" => csrf_token }
      assert_response :forbidden
    end
  end
end
