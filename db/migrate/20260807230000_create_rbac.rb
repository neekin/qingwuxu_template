# frozen_string_literal: true

# RBAC 五表（阶段 0 共享地基）
# roles / permissions / role_permissions / user_roles / menus
# 最小授权单元是「权限点 permission.code」，角色只是权限点的打包容器。
# 注意：菜单类型列命名为 menu_type（避开 Rails STI 保留字 type）。
class CreateRbac < ActiveRecord::Migration[8.1]
  def change
    # ---- 角色 ----
    create_table :roles do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.integer :status, null: false, default: 1 # 0=禁用 1=启用
      t.timestamps
    end
    add_index :roles, :code, unique: true

    # ---- 权限点（最小授权单元）----
    create_table :permissions do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :resource
      t.string :action
      t.text :description
      t.timestamps
    end
    add_index :permissions, :code, unique: true

    # ---- 角色 ⇄ 权限 关联 ----
    create_table :role_permissions do |t|
      t.bigint :role_id, null: false
      t.bigint :permission_id, null: false
      t.timestamps
    end
    add_foreign_key :role_permissions, :roles, on_delete: :cascade
    add_foreign_key :role_permissions, :permissions, on_delete: :cascade
    add_index :role_permissions, %i[role_id permission_id], unique: true

    # ---- 用户 ⇄ 角色 关联 ----
    create_table :user_roles do |t|
      t.bigint :user_id, null: false
      t.bigint :role_id, null: false
      t.timestamps
    end
    add_foreign_key :user_roles, :users, on_delete: :cascade
    add_foreign_key :user_roles, :roles, on_delete: :cascade
    add_index :user_roles, %i[user_id role_id], unique: true

    # ---- 菜单（树，menu_type 避开 STI 保留字）----
    create_table :menus do |t|
      t.bigint :parent_id
      t.string :name, null: false
      t.integer :menu_type, null: false, default: 1 # 0=目录 1=菜单 2=按钮
      t.string :route                      # 前端路由 path（对齐 adminMenu.tsx path）
      t.string :component                  # 前端组件（预留）
      t.string :permission_code            # 关联权限字符（对齐 adminMenu.tsx permission）
      t.string :icon
      t.integer :sort, null: false, default: 0
      t.integer :status, null: false, default: 1 # 0=隐藏 1=显示
      t.timestamps
    end
    add_foreign_key :menus, :menus, column: :parent_id, on_delete: :cascade
    add_index :menus, :parent_id
  end
end
