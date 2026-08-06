# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :email
      t.string :phone, null: false
      t.string :password_digest
      t.integer :status, null: false, default: 1
      t.boolean :super_admin, null: false, default: false
      t.datetime :last_login_at
      t.string :login_ip
      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
  end
end
