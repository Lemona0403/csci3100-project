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

ActiveRecord::Schema[7.1].define(version: 2026_11_24_150000) do
  create_table "claims", force: :cascade do |t|
    t.integer "facility_id", null: false
    t.integer "user_id", null: false
    t.integer "item_id", null: false
    t.integer "status", null: false
    t.string "contact_info", null: false
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_id"], name: "index_claims_on_facility_id"
    t.index ["item_id"], name: "index_claims_on_item_id"
    t.index ["user_id"], name: "index_claims_on_user_id"
  end

  create_table "facilities", force: :cascade do |t|
    t.string "name", null: false
    t.string "location", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_facilities_on_name", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", null: false
    t.integer "category", null: false
    t.integer "status", null: false
    t.datetime "date_found", null: false
    t.integer "facility_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_id"], name: "index_items_on_facility_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.integer "role", null: false
    t.integer "facility_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["facility_id"], name: "index_users_on_facility_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.check_constraint "(role = 1 AND facility_id IS NOT NULL) OR (role = 0 AND facility_id IS NULL)", name: "role_check_for_user"
  end

  add_foreign_key "claims", "facilities"
  add_foreign_key "claims", "items"
  add_foreign_key "claims", "users"
  add_foreign_key "items", "facilities"
  add_foreign_key "users", "facilities"
end
