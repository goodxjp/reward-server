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

ActiveRecord::Schema.define(version: 20150428092200) do

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "advertisements", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "price"
    t.integer  "payment"
    t.integer  "point"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "advertisements", ["campaign_id"], name: "index_advertisements_on_campaign_id"

  create_table "campaign_categories", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", force: true do |t|
    t.string   "name"
    t.text     "detail"
    t.string   "icon_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "network_id"
    t.string   "url"
    t.integer  "campaign_category_id"
    t.string   "requirement"
    t.text     "requirement_detail"
    t.string   "period"
  end

  add_index "campaigns", ["campaign_category_id"], name: "index_campaigns_on_campaign_category_id"
  add_index "campaigns", ["network_id"], name: "index_campaigns_on_network_id"

  create_table "campaigns_media", id: false, force: true do |t|
    t.integer "campaign_id", null: false
    t.integer "medium_id",   null: false
  end

  add_index "campaigns_media", ["campaign_id"], name: "index_campaigns_media_on_campaign_id"
  add_index "campaigns_media", ["medium_id"], name: "index_campaigns_media_on_medium_id"

  create_table "click_histories", force: true do |t|
    t.integer  "media_user_id"
    t.integer  "offer_id"
    t.text     "request_info"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "click_histories", ["media_user_id"], name: "index_click_histories_on_media_user_id"
  add_index "click_histories", ["offer_id"], name: "index_click_histories_on_offer_id"

  create_table "media", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media_users", force: true do |t|
    t.string   "terminal_id"
    t.text     "terminal_info"
    t.string   "android_registration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offers", force: true do |t|
    t.integer  "campaign_id",                         null: false
    t.integer  "medium_id",                           null: false
    t.integer  "campaign_category_id"
    t.string   "name"
    t.text     "detail"
    t.string   "icon_url"
    t.string   "url"
    t.string   "requirement"
    t.text     "requirement_detail"
    t.string   "period"
    t.integer  "price"
    t.integer  "payment"
    t.integer  "point"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "available",            default: true, null: false
  end

  add_index "offers", ["campaign_category_id"], name: "index_offers_on_campaign_category_id"
  add_index "offers", ["campaign_id"], name: "index_offers_on_campaign_id"
  add_index "offers", ["medium_id"], name: "index_offers_on_medium_id"

end
