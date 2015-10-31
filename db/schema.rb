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

ActiveRecord::Schema.define(version: 20151031125632) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.integer  "media_user_id"
    t.integer  "payment",                              null: false
    t.boolean  "payment_is_including_tax"
    t.integer  "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "occurred_at",                          null: false
    t.integer  "notification_id"
    t.string   "notification_type",        limit: 255
    t.datetime "sales_at"
  end

  add_index "achievements", ["campaign_id"], name: "index_achievements_on_campaign_id", using: :btree
  add_index "achievements", ["media_user_id"], name: "index_achievements_on_media_user_id", using: :btree
  add_index "achievements", ["notification_id", "notification_type"], name: "index_achievements_on_notification_id_and_notification_type", using: :btree
  add_index "achievements", ["occurred_at"], name: "index_achievements_on_occurred_at", using: :btree
  add_index "achievements", ["sales_at"], name: "index_achievements_on_sales_at", using: :btree

  create_table "adcrops_achievement_notices", force: :cascade do |t|
    t.integer  "campaign_source_id"
    t.string   "suid",               limit: 255
    t.string   "xuid",               limit: 255
    t.string   "sad",                limit: 255
    t.string   "xad",                limit: 255
    t.string   "cv_id",              limit: 255
    t.string   "reward",             limit: 255
    t.string   "point",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "adcrops_achievement_notices", ["campaign_source_id", "cv_id"], name: "index_adcrops_an_on_campaign_source_id_and_cv_id", using: :btree
  add_index "adcrops_achievement_notices", ["campaign_source_id"], name: "index_adcrops_achievement_notices_on_campaign_source_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "campaign_categories", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_sources", force: :cascade do |t|
    t.integer  "network_id",                    null: false
    t.string   "name",              limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "network_system_id"
  end

  add_index "campaign_sources", ["network_id"], name: "index_campaign_sources_on_network_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "name",                       limit: 255,                 null: false
    t.text     "detail"
    t.string   "icon_url",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",                        limit: 255
    t.integer  "campaign_category_id"
    t.string   "requirement",                limit: 255
    t.text     "requirement_detail"
    t.string   "period",                     limit: 255
    t.integer  "price",                                  default: 0,     null: false
    t.integer  "payment",                                default: 0,     null: false
    t.integer  "point"
    t.integer  "campaign_source_id"
    t.string   "source_campaign_identifier", limit: 255
    t.integer  "source_id"
    t.string   "source_type",                limit: 255
    t.integer  "network_id"
    t.boolean  "available",                              default: true,  null: false
    t.boolean  "payment_is_including_tax",               default: false, null: false
  end

  add_index "campaigns", ["campaign_category_id"], name: "index_campaigns_on_campaign_category_id", using: :btree
  add_index "campaigns", ["campaign_source_id"], name: "index_campaigns_on_campaign_source_id", using: :btree
  add_index "campaigns", ["network_id"], name: "index_campaigns_on_network_id", using: :btree
  add_index "campaigns", ["source_id", "source_type"], name: "index_campaigns_on_source_id_and_source_type", using: :btree

  create_table "campaigns_media", id: false, force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "medium_id",   null: false
  end

  add_index "campaigns_media", ["campaign_id"], name: "index_campaigns_media_on_campaign_id", using: :btree
  add_index "campaigns_media", ["medium_id"], name: "index_campaigns_media_on_medium_id", using: :btree

  create_table "click_histories", force: :cascade do |t|
    t.integer  "media_user_id"
    t.integer  "offer_id"
    t.text     "request_info"
    t.string   "ip_address",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "click_histories", ["media_user_id"], name: "index_click_histories_on_media_user_id", using: :btree
  add_index "click_histories", ["offer_id"], name: "index_click_histories_on_offer_id", using: :btree

  create_table "configs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gifts", force: :cascade do |t|
    t.integer  "item_id",                   null: false
    t.string   "code",          limit: 255, null: false
    t.datetime "expiration_at"
    t.integer  "purchase_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gifts", ["item_id"], name: "index_gifts_on_item_id", using: :btree
  add_index "gifts", ["purchase_id"], name: "index_gifts_on_purchase_id", using: :btree

  create_table "gree_achievement_notices", force: :cascade do |t|
    t.integer  "campaign_source_id"
    t.string   "identifier",         limit: 255
    t.string   "achieve_id",         limit: 255
    t.string   "point",              limit: 255
    t.string   "campaign_id",        limit: 255
    t.string   "advertisement_id",   limit: 255
    t.string   "media_session",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gree_achievement_notices", ["campaign_source_id", "achieve_id"], name: "index_gree_an_on_campaign_source_id_and_achieve_id", using: :btree
  add_index "gree_achievement_notices", ["campaign_source_id", "identifier", "advertisement_id"], name: "index_gree_an_on_cs_id_and_identifier_and_ad_id", using: :btree
  add_index "gree_achievement_notices", ["campaign_source_id"], name: "index_gree_achievement_notices_on_campaign_source_id", using: :btree

  create_table "gree_configs", force: :cascade do |t|
    t.integer  "campaign_source_id",             null: false
    t.integer  "media_identifier",               null: false
    t.string   "site_key",           limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gree_configs", ["campaign_source_id"], name: "index_gree_configs_on_campaign_source_id", using: :btree

  create_table "hidings", force: :cascade do |t|
    t.integer  "media_user_id"
    t.integer  "target_id"
    t.string   "target_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hidings", ["media_user_id"], name: "index_hidings_on_media_user_id", using: :btree
  add_index "hidings", ["target_id", "target_type"], name: "index_hidings_on_target_id_and_target_type", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "name",       limit: 255,                null: false
    t.integer  "point",                                 null: false
    t.boolean  "available",              default: true, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "media", force: :cascade do |t|
    t.string   "name",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "key",                       limit: 255, default: "", null: false
    t.integer  "media_type_id"
    t.integer  "at_least_app_version_code"
  end

  create_table "media_user_updates", force: :cascade do |t|
    t.integer  "media_user_id"
    t.datetime "last_access_at"
    t.integer  "app_version_code"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "media_user_updates", ["media_user_id"], name: "index_media_user_updates_on_media_user_id", using: :btree

  create_table "media_users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "point",                   default: 0,    null: false
    t.integer  "total_point",             default: 0,    null: false
    t.integer  "medium_id"
    t.string   "key",         limit: 255
    t.boolean  "available",               default: true, null: false
  end

  add_index "media_users", ["medium_id"], name: "index_media_users_on_medium_id", using: :btree

  create_table "networks", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offers", force: :cascade do |t|
    t.integer  "campaign_id",                                          null: false
    t.integer  "medium_id",                                            null: false
    t.integer  "campaign_category_id"
    t.string   "name",                     limit: 255
    t.text     "detail"
    t.string   "icon_url",                 limit: 255
    t.string   "url",                      limit: 255
    t.string   "requirement",              limit: 255
    t.text     "requirement_detail"
    t.string   "period",                   limit: 255
    t.integer  "price"
    t.integer  "payment"
    t.integer  "point"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "available",                            default: true,  null: false
    t.boolean  "payment_is_including_tax",             default: false, null: false
  end

  add_index "offers", ["campaign_category_id"], name: "index_offers_on_campaign_category_id", using: :btree
  add_index "offers", ["campaign_id"], name: "index_offers_on_campaign_id", using: :btree
  add_index "offers", ["medium_id"], name: "index_offers_on_medium_id", using: :btree

  create_table "point_histories", force: :cascade do |t|
    t.integer  "media_user_id"
    t.integer  "point_change"
    t.string   "detail",        limit: 255
    t.integer  "source_id"
    t.string   "source_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "point_histories", ["media_user_id"], name: "index_point_histories_on_media_user_id", using: :btree
  add_index "point_histories", ["source_id", "source_type"], name: "index_point_histories_on_source_id_and_source_type", using: :btree

  create_table "points", force: :cascade do |t|
    t.integer  "media_user_id"
    t.string   "source_type",   limit: 255
    t.integer  "source_id"
    t.integer  "point"
    t.integer  "point_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "remains",                                                   null: false
    t.datetime "expiration_at"
    t.datetime "occurred_at",               default: '2000-01-01 00:00:00', null: false
    t.boolean  "available",                 default: true,                  null: false
  end

  add_index "points", ["available"], name: "index_points_on_available", using: :btree
  add_index "points", ["media_user_id"], name: "index_points_on_media_user_id", using: :btree
  add_index "points", ["occurred_at"], name: "index_points_on_occurred_at", using: :btree

  create_table "purchases", force: :cascade do |t|
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

  create_table "terminal_androids", force: :cascade do |t|
    t.integer  "media_user_id"
    t.string   "identifier"
    t.text     "info"
    t.string   "android_version"
    t.string   "android_registration_id"
    t.boolean  "available"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "terminal_androids", ["media_user_id"], name: "index_terminal_androids_on_media_user_id", using: :btree

  add_foreign_key "media_user_updates", "media_users"
  add_foreign_key "terminal_androids", "media_users"
end
