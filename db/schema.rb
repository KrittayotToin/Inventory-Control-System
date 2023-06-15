# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_05_29_084409) do

  create_table "equipment", force: :cascade do |t|
    t.string "equipment_code"
    t.string "equipment_type"
    t.string "equipment_name"
    t.string "equipment_serial_number"
    t.integer "equipment_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "equipment_status"
  end

  create_table "log_controls", force: :cascade do |t|
    t.integer "equipment_id"
    t.integer "member_id"
    t.string "log_status"
    t.date "log_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "amount"
  end

  create_table "members", force: :cascade do |t|
    t.string "member_code"
    t.string "member_name"
    t.string "member_phone"
    t.string "member_email"
    t.string "member_department"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.decimal "fee"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "package"
    t.decimal "cod_minimum_fee"
    t.decimal "cod_percentage_fee"
    t.decimal "ccod_percentage_fee"
    t.string "price_type"
    t.float "cod_percent"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0
    t.string "provider"
    t.string "uid"
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
