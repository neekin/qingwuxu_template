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

ActiveRecord::Schema[8.1].define(version: 2026_08_07_030001) do
  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "last_login_at"
    t.string "login_ip"
    t.string "password_digest"
    t.string "phone", null: false
    t.integer "status", default: 1, null: false
    t.boolean "super_admin", default: false, null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
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
end
