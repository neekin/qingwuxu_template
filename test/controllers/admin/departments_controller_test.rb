# frozen_string_literal: true

require "test_helper"

module Admin
  # 部门管理控制器：三态验证（未登录跳登录 / 无权限 403 / 超管放行 + 写路径成功失败）
  class DepartmentsControllerTest < ActionDispatch::IntegrationTest
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
    test "未登录访问部门列表跳登录" do
      get admin_departments_path
      assert_redirected_to admin_login_path
    end

    test "无权限用户访问部门列表被拦(403)" do
      login_as(@guest)
      get admin_departments_path
      assert_response :forbidden
    end

    test "超管访问部门列表放行" do
      login_as(@super)
      get admin_departments_path
      assert_response :success
    end

    # ---- create 三态 ----
    test "未登录创建部门跳登录" do
      get root_path
      post admin_departments_path,
           params: { department: { code: "d1", name: "测试部" } },
           headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_login_path
    end

    test "无权限用户创建部门被拦(403)" do
      login_as(@guest)
      get root_path
      post admin_departments_path,
           params: { department: { code: "d1", name: "测试部" } },
           headers: { "X-CSRF-Token" => csrf_token }
      assert_response :forbidden
    end

    test "超管创建部门成功(重定向刷新列表)" do
      login_as(@super)
      get root_path
      assert_difference -> { Department.count }, 1 do
        post admin_departments_path,
             params: { department: { code: "d1", name: "测试部" } },
             headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_departments_path
    end

    test "超管创建部门带非法参数返回 422" do
      login_as(@super)
      get root_path
      assert_no_difference -> { Department.count } do
        post admin_departments_path,
             params: { department: { code: "", name: "" } },
             headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_response :unprocessable_entity
    end

    # ---- update ----
    test "超管更新部门成功" do
      login_as(@super)
      dept = Department.create!(code: "u1", name: "原部门")
      get root_path
      put admin_department_path(dept),
          params: { department: { name: "改部门" } },
          headers: { "X-CSRF-Token" => csrf_token }
      assert_redirected_to admin_departments_path
      assert_equal "改部门", dept.reload.name
    end

    test "超管更新部门带非法参数返回 422" do
      login_as(@super)
      dept = Department.create!(code: "u2", name: "原部门")
      get root_path
      put admin_department_path(dept),
          params: { department: { code: "" } },
          headers: { "X-CSRF-Token" => csrf_token }
      assert_response :unprocessable_entity
    end

    # ---- destroy ----
    test "超管删除部门成功" do
      login_as(@super)
      dept = Department.create!(code: "d2", name: "删部门")
      get root_path
      assert_difference -> { Department.count }, -1 do
        delete admin_department_path(dept),
               headers: { "X-CSRF-Token" => csrf_token }
      end
      assert_redirected_to admin_departments_path
    end

    test "无权限用户删除部门被拦(403)" do
      login_as(@guest)
      dept = Department.create!(code: "d3", name: "删部门")
      get root_path
      delete admin_department_path(dept),
             headers: { "X-CSRF-Token" => csrf_token }
      assert_response :forbidden
    end
  end
end
