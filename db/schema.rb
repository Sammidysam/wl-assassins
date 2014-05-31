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

ActiveRecord::Schema.define(version: 20140531220653) do

  create_table "contracts", force: true do |t|
    t.boolean  "completed"
    t.integer  "participation_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: true do |t|
    t.string   "name"
    t.boolean  "in_progress"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kills", force: true do |t|
    t.boolean  "confirmed"
    t.string   "how"
    t.integer  "participation_id"
    t.integer  "target_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", force: true do |t|
    t.string   "name"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participations", force: true do |t|
    t.boolean  "eliminated"
    t.integer  "team_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.boolean  "admin"
    t.boolean  "out_of_town"
    t.float    "willing_to_pay_amount"
    t.float    "paid_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
