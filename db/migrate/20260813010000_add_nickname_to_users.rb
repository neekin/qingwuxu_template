# frozen_string_literal: true

# 个人中心：用户昵称（头像走 Active Storage，无需新增列）。
class AddNicknameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :nickname, :string
  end
end
