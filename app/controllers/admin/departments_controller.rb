# frozen_string_literal: true

module Admin
  # 部门管理（树形，真实写路径：create/update/destroy 走 Inertia POST/PUT/DELETE）。
  # 后端范式：成功 → redirect_to index（Inertia 客户端自动跟随 GET 刷新列表）；
  #          校验失败 → render inertia: 同页 + errors，返回 422（前端 ModalForm 保持打开）。
  class DepartmentsController < BaseController
    def index
      authorize! Department, to: :index?
      render inertia: "admin/departments/index", props: departments_props
    end

    def create
      authorize! Department, to: :create?
      dept = Department.new(department_params)
      if dept.save
        redirect_to admin_departments_path
      else
        render inertia: "admin/departments/index",
               props: departments_props.merge(errors: dept.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def update
      authorize! Department, to: :update?
      dept = scoped.find(params[:id])
      if dept.update(department_params)
        redirect_to admin_departments_path
      else
        render inertia: "admin/departments/index",
               props: departments_props.merge(errors: dept.errors.full_messages),
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize! Department, to: :destroy?
      scoped.find(params[:id]).destroy
      redirect_to admin_departments_path
    end

    private

    # IDOR 防线：列表/写操作都过 policy_scope（超管全量 / 普通按权限过滤）。
    def scoped
      policy_scope(Department.all, with: DepartmentPolicy)
    end

    # 平铺列表 + parent 名称列（KISS：前端按 parent_id 可递归成树）。
    def departments_props
      depts = scoped.tree
      by_id = depts.index_by(&:id)
      {
        departments: depts.map do |d|
          {
            id: d.id,
            code: d.code,
            name: d.name,
            parent_id: d.parent_id,
            parent_name: d.parent_id ? by_id[d.parent_id]&.name : nil,
            leader: d.leader,
            sort: d.sort,
            status: d.status,
            remark: d.remark,
            created_at: d.created_at.strftime("%Y-%m-%d %H:%M")
          }
        end
      }
    end

    # 前端 ProListPage 发裸 values（无 :department 包裹），用 permit 直接收。
    def department_params
      params.permit(:code, :name, :parent_id, :leader, :sort, :status, :remark)
    end
  end
end
