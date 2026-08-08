# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_08_020000) do
  create_table "departments", force: :cascade do |t|
    t.string "ancestors"
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "leader"
    t.string "name", null: false
    t.bigint "parent_id"
    t.text "remark"
    t.integer "sort", default: 0, null: false
    t.integer "status", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
    t.index ["parent_id"], name: "index_departments_on_parent_id"
  end

  create_table "dictionary_data", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dict_type", null: false
    t.string "label", null: false
    t.text "remark"
    t.integer "sort", default: 0, null: false
    t.integer "status", default: 1, null: false
    t.datetime "updated_at", null: false
    t.string "value", null: false
    t.index ["dict_type"], name: "index_dictionary_data_on_dict_type"
  end

  create_table "dictionary_types", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.text "remark"
    t.integer "sort", default: 0, null: false
    t.integer "status", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_dictionary_types_on_code", unique: true
  end

  create_table "login_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip"
    t.datetime "last_seen_at"
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.integer "user_id", null: false
    t.index ["token"], name: "index_login_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_login_sessions_on_user_id"
  end

  create_table "menus", force: :cascade do |t|
    t.string "component"
    t.datetime "created_at", null: false
    t.string "icon"
    t.integer "menu_type", default: 1, null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.string "permission_code"
    t.string "route"
    t.integer "sort", default: 0, null: false
    t.integer "status", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_menus_on_parent_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.string "action"
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "resource"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_permissions_on_code", unique: true
  end

  create_table "role_permissions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "permission_id", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "status", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_roles_on_code", unique: true
  end

  create_table "user_roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "role_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "data_scope", default: 0, null: false
    t.integer "department_id"
    t.string "email"
    t.datetime "last_login_at"
    t.string "login_ip"
    t.string "password_digest"
    t.string "phone", null: false
    t.integer "status", default: 1, null: false
    t.boolean "super_admin", default: false, null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "verification_codes", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.string "channel", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "purpose", default: "login", null: false
    t.string "receiver", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.index ["receiver", "channel", "purpose"], name: "index_verification_codes_on_receiver_and_channel_and_purpose"
  end

  add_foreign_key "login_sessions", "users", on_delete: :cascade
  add_foreign_key "menus", "menus", column: "parent_id", on_delete: :cascade
  add_foreign_key "role_permissions", "permissions", on_delete: :cascade
  add_foreign_key "role_permissions", "roles", on_delete: :cascade
  add_foreign_key "user_roles", "roles", on_delete: :cascade
  add_foreign_key "user_roles", "users", on_delete: :cascade
  add_foreign_key "users", "departments", on_delete: :nullify
end
