# frozen_string_literal: true

# 登录日志（MVP P0 真后端）：记录后台登录成败（账号/密码/短信等方式），支撑「登录日志」审计页。
class CreateLoginLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :login_logs do |t|
      t.references :user, null: true, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :username
      t.string :ip
      t.text :user_agent
      t.string :login_type
      t.string :status, default: "success", null: false
      t.text :message
      t.timestamps
    end
    add_index :login_logs, :created_at
  end
end
