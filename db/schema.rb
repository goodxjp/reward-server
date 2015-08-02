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

ActiveRecord::Schema.define(version: 20150802000129) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievements", force: true do |t|
    t.integer  "media_user_id"
    t.integer  "payment",             null: false
    t.boolean  "payment_include_tax"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "occurred_at",         null: false
    t.integer  "notification_id"
    t.string   "notification_type"
  end

  add_index "achievements", ["campaign_id"], name: "index_achievements_on_campaign_id", using: :btree
  add_index "achievements", ["media_user_id"], name: "index_achievements_on_media_user_id", using: :btree
  add_index "achievements", ["notification_id", "notification_type"], name: "index_achievements_on_notification_id_and_notification_type", using: :btree
  add_index "achievements", ["occurred_at"], name: "index_achievements_on_occurred_at", using: :btree

  create_table "adcrops_achievement_notices", force: true do |t|
    t.integer  "campaign_source_id"
    t.string   "suid"
    t.string   "xuid"
    t.string   "sad"
    t.string   "xad"
    t.string   "cv_id"
    t.string   "reward"
    t.string   "point"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "adcrops_achievement_notices", ["campaign_source_id", "cv_id"], name: "index_adcrops_an_on_campaign_source_id_and_cv_id", using: :btree
  add_index "adcrops_achievement_notices", ["campaign_source_id"], name: "index_adcrops_achievement_notices_on_campaign_source_id", using: :btree

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

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "advertisements", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "price"
    t.integer  "payment"
    t.integer  "point"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "advertisements", ["campaign_id"], name: "index_advertisements_on_campaign_id", using: :btree

  create_table "campaign_categories", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_sources", force: true do |t|
    t.integer  "network_id",        null: false
    t.string   "name",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "network_system_id"
  end

  add_index "campaign_sources", ["network_id"], name: "index_campaign_sources_on_network_id", using: :btree

  create_table "campaigns", force: true do |t|
    t.string   "name",                                   null: false
    t.text     "detail"
    t.string   "icon_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.integer  "campaign_category_id"
    t.string   "requirement"
    t.text     "requirement_detail"
    t.string   "period"
    t.integer  "price",                      default: 0, null: false
    t.integer  "payment",                    default: 0, null: false
    t.integer  "point"
    t.integer  "campaign_source_id"
    t.string   "source_campaign_identifier"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "network_id"
  end

  add_index "campaigns", ["campaign_category_id"], name: "index_campaigns_on_campaign_category_id", using: :btree
  add_index "campaigns", ["campaign_source_id"], name: "index_campaigns_on_campaign_source_id", using: :btree
  add_index "campaigns", ["network_id"], name: "index_campaigns_on_network_id", using: :btree
  add_index "campaigns", ["source_id", "source_type"], name: "index_campaigns_on_source_id_and_source_type", using: :btree

  create_table "campaigns_media", id: false, force: true do |t|
    t.integer "campaign_id", null: false
    t.integer "medium_id",   null: false
  end

  add_index "campaigns_media", ["campaign_id"], name: "index_campaigns_media_on_campaign_id", using: :btree
  add_index "campaigns_media", ["medium_id"], name: "index_campaigns_media_on_medium_id", using: :btree

  create_table "click_histories", force: true do |t|
    t.integer  "media_user_id"
    t.integer  "offer_id"
    t.text     "request_info"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "click_histories", ["media_user_id"], name: "index_click_histories_on_media_user_id", using: :btree
  add_index "click_histories", ["offer_id"], name: "index_click_histories_on_offer_id", using: :btree

  create_table "gifts", force: true do |t|
    t.integer  "item_id",       null: false
    t.string   "code",          null: false
    t.datetime "expiration_at"
    t.integer  "purchase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gifts", ["item_id"], name: "index_gifts_on_item_id", using: :btree
  add_index "gifts", ["purchase_id"], name: "index_gifts_on_purchase_id", using: :btree

  create_table "gree_achievement_notices", force: true do |t|
    t.integer  "campaign_source_id"
    t.string   "identifier"
    t.string   "achieve_id"
    t.string   "point"
    t.string   "campaign_id"
    t.string   "advertisement_id"
    t.string   "media_session"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gree_achievement_notices", ["campaign_source_id", "achieve_id"], name: "index_gree_an_on_campaign_source_id_and_achieve_id", using: :btree
  add_index "gree_achievement_notices", ["campaign_source_id", "identifier", "advertisement_id"], name: "index_gree_an_on_cs_id_and_identifier_and_ad_id", using: :btree
  add_index "gree_achievement_notices", ["campaign_source_id"], name: "index_gree_achievement_notices_on_campaign_source_id", using: :btree

  create_table "hidings", force: true do |t|
    t.integer  "media_user_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hidings", ["media_user_id"], name: "index_hidings_on_media_user_id", using: :btree
  add_index "hidings", ["target_id", "target_type"], name: "index_hidings_on_target_id_and_target_type", using: :btree

  create_table "items", force: true do |t|
    t.string   "name",                      null: false
    t.integer  "point",                     null: false
    t.boolean  "available",  default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key",        default: "", null: false
  end

  create_table "media_users", force: true do |t|
    t.string   "terminal_id"
    t.text     "terminal_info"
    t.string   "android_registration_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "point",                   default: 0, null: false
    t.integer  "total_point",             default: 0, null: false
    t.integer  "medium_id"
    t.string   "key"
  end

  add_index "media_users", ["medium_id"], name: "index_media_users_on_medium_id", using: :btree

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

  add_index "offers", ["campaign_category_id"], name: "index_offers_on_campaign_category_id", using: :btree
  add_index "offers", ["campaign_id"], name: "index_offers_on_campaign_id", using: :btree
  add_index "offers", ["medium_id"], name: "index_offers_on_medium_id", using: :btree

  create_table "point_histories", force: true do |t|
    t.integer  "media_user_id"
    t.integer  "point_change"
    t.string   "detail"
    t.integer  "source_id"
    t.string   "source_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "point_histories", ["media_user_id"], name: "index_point_histories_on_media_user_id", using: :btree
  add_index "point_histories", ["source_id", "source_type"], name: "index_point_histories_on_source_id_and_source_type", using: :btree

  create_table "points", force: true do |t|
    t.integer  "media_user_id"
    t.string   "source_type"
    t.integer  "source_id"
    t.integer  "point"
    t.integer  "point_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "remains",       null: false
    t.datetime "expiration_at"
  end

  add_index "points", ["media_user_id"], name: "index_points_on_media_user_id", using: :btree

  create_table "purchases", force: true do |t|
    t.integer  "media_user_id", null: false
    t.integer  "item_id",       null: false
    t.integer  "number",        null: false
    t.integer  "point",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "occurred_at",   null: false
  end

  add_index "purchases", ["item_id"], name: "index_purchases_on_item_id", using: :btree
  add_index "purchases", ["media_user_id"], name: "index_purchases_on_media_user_id", using: :btree
  add_index "purchases", ["occurred_at"], name: "index_purchases_on_occurred_at", using: :btree

end
