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

ActiveRecord::Schema.define(version: 20140613145134) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contracts", force: true do |t|
    t.boolean  "completed"
    t.integer  "participation_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start"
    t.datetime "end"
  end

  create_table "games", force: true do |t|
    t.string   "name"
    t.boolean  "in_progress"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.float    "team_fee"
  end

  create_table "kills", force: true do |t|
    t.boolean  "confirmed"
    t.integer  "participation_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "occurred_at"
    t.string   "picture_url"
    t.text     "how"
  end

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
  end

  create_table "neutralizations", force: true do |t|
    t.boolean  "confirmed"
    t.datetime "start"
    t.integer  "killer_id"
    t.integer  "target_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "how"
  end

  create_table "pages", force: true do |t|
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sort_index"
    t.string   "link"
  end

  create_table "participations", force: true do |t|
    t.boolean  "eliminated"
    t.integer  "team_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "termination_at"
    t.float    "paid_amount"
    t.boolean  "terminators"
  end

  create_table "teams", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_url"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "phone_number"
    t.boolean  "phone_number_public"
    t.string   "address"
    t.boolean  "address_public"
    t.integer  "graduation_year"
    t.text     "description"
    t.string   "profile_picture_url"
    t.boolean  "out_of_town"
    t.float    "willing_to_pay_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_public"
    t.integer  "role",                  default: 0
  end

end
