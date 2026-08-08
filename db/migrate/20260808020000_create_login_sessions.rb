# frozen_string_literal: true

# 在线会话记录：每个后台登录会话对应一条记录，支撑「在线用户」监控与强制下线。
# 强制下线 = 删除该记录；下次请求时 ApplicationController 校验令牌失败即被弹回登录页。
class CreateLoginSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :login_sessions do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :token, null: false
      t.string :ip
      t.text :user_agent
      t.datetime :last_seen_at
      t.timestamps
    end
    add_index :login_sessions, :token, unique: true
  end
end
