# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150622174441) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contracts", force: :cascade do |t|
    t.boolean  "completed",        default: false
    t.integer  "participation_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start"
    t.datetime "end"
  end

  add_index "contracts", ["participation_id"], name: "contract_participation_index", using: :btree
  add_index "contracts", ["target_id"], name: "contract_target_index", using: :btree

  create_table "games", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.boolean  "in_progress",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.float    "team_fee"
  end

  create_table "kills", force: :cascade do |t|
    t.boolean  "confirmed",                default: false
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "confirmed_at"
    t.string   "picture_url",  limit: 255
    t.text     "how"
    t.integer  "kind",                     default: 0
    t.integer  "game_id"
    t.integer  "killer_id"
    t.datetime "appear_at"
  end

  add_index "kills", ["game_id"], name: "kill_game_index", using: :btree
  add_index "kills", ["killer_id"], name: "kill_killer_index", using: :btree
  add_index "kills", ["target_id"], name: "kill_target_index", using: :btree

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "ended_at"
    t.datetime "started_at"
  end

  add_index "memberships", ["team_id"], name: "membership_team_index", using: :btree
  add_index "memberships", ["user_id"], name: "membership_user_index", using: :btree

  create_table "name_changes", force: :cascade do |t|
    t.string   "from"
    t.string   "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "team_id"
  end

  add_index "name_changes", ["team_id"], name: "index_name_changes_on_team_id", using: :btree

  create_table "neutralizations", force: :cascade do |t|
    t.boolean  "confirmed",               default: false
    t.datetime "start"
    t.integer  "killer_id"
    t.integer  "target_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "how"
    t.string   "picture_url", limit: 255
  end

  add_index "neutralizations", ["game_id"], name: "neutralization_game_index", using: :btree
  add_index "neutralizations", ["killer_id"], name: "neutralization_killer_index", using: :btree
  add_index "neutralizations", ["target_id"], name: "neutralization_target_index", using: :btree

  create_table "pages", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_index"
    t.string   "link",       limit: 255
  end

  create_table "participations", force: :cascade do |t|
    t.integer  "team_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "termination_at"
    t.float    "paid_amount"
    t.boolean  "terminators",       default: false
    t.float    "out_of_town_hours", default: 0.0
    t.integer  "place"
  end

  add_index "participations", ["game_id"], name: "participation_game_index", using: :btree
  add_index "participations", ["team_id"], name: "participation_team_index", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_url",    limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "email",                 limit: 255
    t.string   "password_digest",       limit: 255
    t.string   "phone_number",          limit: 255
    t.boolean  "phone_number_public",               default: false
    t.string   "address",               limit: 255
    t.boolean  "address_public",                    default: false
    t.integer  "graduation_year"
    t.text     "description"
    t.string   "profile_picture_url",   limit: 255
    t.boolean  "out_of_town",                       default: false
    t.float    "willing_to_pay_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_public",                      default: false
    t.integer  "role",                              default: 0
    t.boolean  "duplicate",                         default: false
  end

  add_foreign_key "name_changes", "teams"
end
