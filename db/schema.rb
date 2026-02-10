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

ActiveRecord::Schema[8.1].define(version: 2026_02_10_110453) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "tickets", force: :cascade do |t|
    t.integer "assigned_to"
    t.datetime "created_at", null: false
    t.integer "created_by"
    t.text "description"
    t.boolean "is_approval_required", default: false
    t.boolean "is_assigned", default: false
    t.integer "priority"
    t.integer "status", default: 0
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_tickets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "is_active", default: true
    t.string "mobile_no"
    t.string "name"
    t.string "password_digest"
    t.string "role", default: "user"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "tickets", "users"
end
