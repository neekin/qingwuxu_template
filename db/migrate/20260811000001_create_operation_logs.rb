# frozen_string_literal: true

# 操作日志（MVP P0 真后端）：记录后台管理操作（含查询/新增/修改/删除），支撑「操作日志」审计页。
class CreateOperationLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :operation_logs do |t|
      t.references :admin_user, null: true, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :username
      t.string :ip
      t.string :request_method
      t.string :path
      t.string :action
      t.string :title
      t.string :status, default: "success", null: false
      t.text :message
      t.integer :duration_ms
      t.timestamps
    end
    add_index :operation_logs, :created_at
  end
end
