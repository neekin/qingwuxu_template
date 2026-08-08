# frozen_string_literal: true

require "test_helper"

module Admin
  # 字典数据项管理控制器：三态验证（未登录跳登录 / 无权限 403 / 超管放行 + 写路径成功失败）
  # index 支持按 dict_type 过滤；create/update/destroy 校验 dict_type 存在。
  class DictionaryDataControllerTest < ActionDispatch::IntegrationTest
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
      @type = DictionaryType.create!(code: "dt_test", name: "测试类型")
    end

    # ---- index 三态 ----
    test "未登录访问字典数据项列表跳登录" do
      get admin_dictionary_data_path
      assert_redirected_to admin_login_path
    end

    test "无权限用户访问字典数据项列表被拦(403)" do
      login_as(@guest)
      get admin_dictionary_data_path
      assert_response :forbidden
    end

    test "超管访问字典数据项列表放行" do
      login_as(@super)
      get admin_dictionary_data_path
      assert_response :success
    end

    test "超管访问字典数据项按 dict_type 过滤" do
      DictionaryData.create!(dict_type: @type.code, label: "男", value: "0")
      other = DictionaryType.create!(code: "other", name: "其他类型")
      DictionaryData.create!(dict_type: other.code, label: "其它", value: "x")
      login_as(@super)
      get admin_dictionary_data_path, params: { dict_type: @type.code }
      assert_response :success
      body = response.body
      assert_match "男", body
      refute_match "其它", body
    end

    # ---- create 三态 ----
    test "未登录创建字典数据项跳登录" do
      get root_path
      post admin_dictionary_data_path,
           params: { dictionary_data: { dict_type: @type.code, label: "男", value: "0" } },
           headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_login_path
    end

    test "无权限用户创建字典数据项被拦(403)" do
      login_as(@guest)
      get root_path
      post admin_dictionary_data_path,
           params: { dictionary_data: { dict_type: @type.code, label: "男", value: "0" } },
           headers: { "X-CSRF-Token" => csrf_token }
      assert_response :forbidden
    end

    test "超管创建字典数据项成功(重定向刷新列表)" do
      login_as(@super)
      get root_path
      assert_difference -> { DictionaryData.count }, 1 do
        post admin_dictionary_data_path,
             params: { dictionary_data: { dict_type: @type.code, label: "男", value: "0" } },
             headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_dictionary_data_path(dict_type: @type.code)
    end

    test "超管创建字典数据项带不存在的 dict_type 返回 422" do
      login_as(@super)
      get root_path
      assert_no_difference -> { DictionaryData.count } do
        post admin_dictionary_data_path,
             params: { dictionary_data: { dict_type: "nope", label: "男", value: "0" } },
             headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_response :unprocessable_entity
    end

    # ---- update ----
    test "超管更新字典数据项成功" do
      login_as(@super)
      item = DictionaryData.create!(dict_type: @type.code, label: "男", value: "0")
      get root_path
      put admin_dictionary_datum_path(item),
          params: { dictionary_data: { label: "女性" } },
          headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_dictionary_data_path(dict_type: @type.code)
      assert_equal "女性", item.reload.label
    end

    # ---- destroy ----
    test "超管删除字典数据项成功" do
      login_as(@super)
      item = DictionaryData.create!(dict_type: @type.code, label: "男", value: "0")
      get root_path
      assert_difference -> { DictionaryData.count }, -1 do
        delete admin_dictionary_datum_path(item),
               headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_dictionary_data_path(dict_type: @type.code)
    end

    test "无权限用户删除字典数据项被拦(403)" do
      login_as(@guest)
      item = DictionaryData.create!(dict_type: @type.code, label: "男", value: "0")
      get root_path
      delete admin_dictionary_datum_path(item),
             headers: { "X-CSRF-Token" => csrf_token }
      assert_response :forbidden
    end
  end
end
