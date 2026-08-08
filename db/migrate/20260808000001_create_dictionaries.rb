# frozen_string_literal: true

# 字典管理（若依式两表，KISS，不建外键——按 dict_type 字符串关联）
# 一步建两表：dictionary_types（字典类型）+ dictionary_data（字典数据项）。
class CreateDictionaries < ActiveRecord::Migration[8.1]
  def change
    create_table :dictionary_types do |t|
      t.string :code, null: false, comment: "字典类型编码，如 sys_user_sex"
      t.string :name, null: false, comment: "字典类型名称"
      t.integer :status, default: 1, null: false, comment: "0=禁用 1=启用"
      t.text :remark, comment: "备注"
      t.integer :sort, default: 0, null: false, comment: "排序"

      t.timestamps
    end
    add_index :dictionary_types, :code, unique: true

    create_table :dictionary_data do |t|
      t.string :dict_type, null: false, comment: "所属字典类型 code"
      t.string :label, null: false, comment: "数据标签"
      t.string :value, null: false, comment: "数据键值"
      t.integer :sort, default: 0, null: false, comment: "排序"
      t.integer :status, default: 1, null: false, comment: "0=禁用 1=启用"
      t.text :remark, comment: "备注"

      t.timestamps
    end
    add_index :dictionary_data, :dict_type
  end
end
