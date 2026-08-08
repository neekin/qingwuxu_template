# frozen_string_literal: true

# 部门（树形，自引用）。ancestors 存祖先 id 路径（逗号分隔，如 "1,3"），
# 便于「含下级」查询；parent_id 自引用，name/code 为业务字段。
class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments do |t|
      t.string :code, null: false, comment: "部门编码，唯一"
      t.string :name, null: false, comment: "部门名称"
      t.bigint :parent_id, null: true, comment: "上级部门 id，自引用"
      t.string :ancestors, null: true, comment: "祖先 id 路径，逗号分隔，如 1,3"
      t.integer :sort, default: 0, null: false, comment: "排序"
      t.integer :status, default: 1, null: false, comment: "0=禁用 1=启用"
      t.string :leader, null: true, comment: "负责人"
      t.text :remark, null: true, comment: "备注"

      t.timestamps
    end
    add_index :departments, :parent_id
    add_index :departments, :code, unique: true
  end
end
