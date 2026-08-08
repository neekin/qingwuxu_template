# frozen_string_literal: true

# 用户绑定部门 + 数据权限范围。
# - department_id：所属部门（FK 不强制，部门删除允许置空）。
# - data_scope：数据权限范围（0=全部 /1=自定义 /2=本部门 /3=本部门及下级 /4=仅自己）。
class AddDepartmentToUsers < ActiveRecord::Migration[8.1]
  def change
    add_reference :users, :department, foreign_key: { to_table: :departments, on_delete: :nullify }, index: true
    add_column :users, :data_scope, :integer, default: 0, null: false, comment: "数据权限范围 0=全部 1=自定义 2=本部门 3=本部门及下级 4=仅自己"
  end
end
