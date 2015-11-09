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

ActiveRecord::Schema.define(version: 20151107134321) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.integer  "notification_id"
    t.string   "notification_type"
    t.integer  "media_user_id"
    t.integer  "campaign_id"
    t.integer  "payment",                                  null: false
    t.boolean  "payment_is_including_tax", default: false, null: false
    t.datetime "sales_at",                                 null: false
    t.datetime "occurred_at",                              null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "achievements", ["campaign_id"], name: "index_achievements_on_campaign_id", using: :btree
  add_index "achievements", ["media_user_id"], name: "index_achievements_on_media_user_id", using: :btree
  add_index "achievements", ["notification_type", "notification_id"], name: "index_achievements_on_notification_type_and_notification_id", using: :btree
  add_index "achievements", ["occurred_at"], name: "index_achievements_on_occurred_at", using: :btree
  add_index "achievements", ["sales_at"], name: "index_achievements_on_sales_at", using: :btree

  create_table "adcrops_achievement_notices", force: :cascade do |t|
    t.integer  "campaign_source_id"
    t.string   "suid"
    t.string   "xuid"
    t.string   "sad"
    t.string   "xad"
    t.string   "cv_id"
    t.string   "reward"
    t.string   "point"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "adcrops_achievement_notices", ["campaign_source_id", "cv_id"], name: "index_adcrops_achievement_notices_1", using: :btree
  add_index "adcrops_achievement_notices", ["campaign_source_id"], name: "index_adcrops_achievement_notices_on_campaign_source_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
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
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "campaign_categories", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "campaign_sources", force: :cascade do |t|
    t.integer  "network_system_id", null: false
    t.integer  "network_id",        null: false
    t.string   "name",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "campaign_sources", ["network_id"], name: "index_campaign_sources_on_network_id", using: :btree
  add_index "campaign_sources", ["network_system_id"], name: "index_campaign_sources_on_network_system_id", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.integer  "network_id",                                 null: false
    t.integer  "campaign_source_id"
    t.integer  "source_id"
    t.string   "source_type"
    t.string   "source_campaign_identifier"
    t.integer  "campaign_category_id"
    t.string   "name",                                       null: false
    t.text     "detail"
    t.text     "icon_url"
    t.text     "url",                                        null: false
    t.string   "requirement"
    t.text     "requirement_detail"
    t.string   "period"
    t.integer  "price",                      default: 0,     null: false
    t.integer  "payment",                                    null: false
    t.boolean  "payment_is_including_tax",   default: false, null: false
    t.integer  "point"
    t.boolean  "available",                  default: true,  null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "campaigns", ["available"], name: "index_campaigns_on_available", using: :btree
  add_index "campaigns", ["campaign_category_id"], name: "index_campaigns_on_campaign_category_id", using: :btree
  add_index "campaigns", ["campaign_source_id"], name: "index_campaigns_on_campaign_source_id", using: :btree
  add_index "campaigns", ["network_id"], name: "index_campaigns_on_network_id", using: :btree
  add_index "campaigns", ["source_type", "source_id"], name: "index_campaigns_on_source_type_and_source_id", using: :btree

  create_table "campaigns_media", id: false, force: :cascade do |t|
    t.integer "campaign_id", null: false
    t.integer "medium_id",   null: false
  end

  add_index "campaigns_media", ["campaign_id"], name: "index_campaigns_media_on_campaign_id", using: :btree
  add_index "campaigns_media", ["medium_id"], name: "index_campaigns_media_on_medium_id", using: :btree

  create_table "click_histories", force: :cascade do |t|
    t.integer  "media_user_id",            null: false
    t.integer  "offer_id",                 null: false
    t.text     "request_info"
    t.string   "ip_address",    limit: 45
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "click_histories", ["media_user_id"], name: "index_click_histories_on_media_user_id", using: :btree
  add_index "click_histories", ["offer_id"], name: "index_click_histories_on_offer_id", using: :btree

  create_table "configs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gifts", force: :cascade do |t|
    t.integer  "item_id",       null: false
    t.integer  "purchase_id"
    t.string   "code",          null: false
    t.datetime "expiration_at"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "gifts", ["item_id"], name: "index_gifts_on_item_id", using: :btree
  add_index "gifts", ["purchase_id"], name: "index_gifts_on_purchase_id", using: :btree

  create_table "gree_achievement_notices", force: :cascade do |t|
    t.integer  "campaign_source_id", null: false
    t.string   "identifier"
    t.string   "achieve_id"
    t.string   "point"
    t.string   "campaign_id"
    t.string   "advertisement_id"
    t.string   "media_session"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "gree_achievement_notices", ["campaign_source_id", "achieve_id"], name: "index_gree_achievement_notices_1", using: :btree
  add_index "gree_achievement_notices", ["campaign_source_id", "identifier", "advertisement_id"], name: "index_gree_achievement_notices_2", using: :btree
  add_index "gree_achievement_notices", ["campaign_source_id"], name: "index_gree_achievement_notices_on_campaign_source_id", using: :btree

  create_table "gree_campaigns", force: :cascade do |t|
    t.integer  "campaign_source_id",                        null: false
    t.integer  "site_price"
    t.string   "icon_url"
    t.integer  "thanks_count"
    t.integer  "thanks_media_revenue"
    t.string   "thanks_thanks_name"
    t.integer  "thanks_thanks_point"
    t.integer  "thanks_thanks_category"
    t.integer  "thanks_thanks_period"
    t.integer  "campaign_identifier"
    t.integer  "subscription_duration"
    t.string   "carrier"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "is_url_scheme"
    t.string   "site_price_currency"
    t.text     "site_description"
    t.string   "site_name"
    t.integer  "campaign_category"
    t.string   "market_app_id"
    t.string   "click_url"
    t.string   "default_thanks_name"
    t.integer  "number_of_max_action_daily"
    t.integer  "daily_action_left_in_stock"
    t.integer  "number_of_max_action"
    t.text     "draft"
    t.integer  "platform_identifier"
    t.integer  "duplication_type"
    t.string   "duplication_date"
    t.boolean  "available",                  default: true, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "gree_campaigns", ["available"], name: "index_gree_campaigns_on_available", using: :btree
  add_index "gree_campaigns", ["campaign_source_id"], name: "index_gree_campaigns_on_campaign_source_id", using: :btree

  create_table "gree_configs", force: :cascade do |t|
    t.integer  "campaign_source_id", null: false
    t.integer  "site_identifier",    null: false
    t.integer  "media_identifier",   null: false
    t.string   "site_key",           null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "gree_configs", ["campaign_source_id"], name: "index_gree_configs_on_campaign_source_id", using: :btree

  create_table "hidings", force: :cascade do |t|
    t.integer  "media_user_id", null: false
    t.integer  "target_id",     null: false
    t.string   "target_type",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "hidings", ["media_user_id"], name: "index_hidings_on_media_user_id", using: :btree
  add_index "hidings", ["target_type", "target_id"], name: "index_hidings_on_target_type_and_target_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "name",                      null: false
    t.integer  "point",                     null: false
    t.boolean  "available",  default: true, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "media", force: :cascade do |t|
    t.integer  "media_type_id"
    t.string   "name",                      null: false
    t.string   "key",                       null: false
    t.integer  "at_least_app_version_code"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "media_user_updates", force: :cascade do |t|
    t.integer  "media_user_id",    null: false
    t.datetime "last_access_at",   null: false
    t.integer  "app_version_code", null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "media_user_updates", ["media_user_id"], name: "index_media_user_updates_on_media_user_id", using: :btree

  create_table "media_users", force: :cascade do |t|
    t.integer  "medium_id",                             null: false
    t.string   "key",         limit: 16,                null: false
    t.integer  "point",                  default: 0,    null: false
    t.integer  "total_point",            default: 0,    null: false
    t.boolean  "available",              default: true, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "media_users", ["medium_id"], name: "index_media_users_on_medium_id", using: :btree

  create_table "networks", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "offers", force: :cascade do |t|
    t.integer  "campaign_id",                              null: false
    t.integer  "medium_id",                                null: false
    t.integer  "campaign_category_id"
    t.string   "name",                                     null: false
    t.text     "detail"
    t.text     "icon_url"
    t.text     "url",                                      null: false
    t.string   "requirement"
    t.text     "requirement_detail"
    t.string   "period"
    t.integer  "price",                    default: 0,     null: false
    t.integer  "payment",                                  null: false
    t.boolean  "payment_is_including_tax", default: false, null: false
    t.integer  "point",                                    null: false
    t.boolean  "available",                default: true,  null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "offers", ["available"], name: "index_offers_on_available", using: :btree
  add_index "offers", ["campaign_category_id"], name: "index_offers_on_campaign_category_id", using: :btree
  add_index "offers", ["campaign_id"], name: "index_offers_on_campaign_id", using: :btree
  add_index "offers", ["medium_id"], name: "index_offers_on_medium_id", using: :btree

  create_table "point_histories", force: :cascade do |t|
    t.integer  "media_user_id", null: false
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "point_change"
    t.string   "detail"
    t.datetime "occurred_at",   null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "point_histories", ["media_user_id"], name: "index_point_histories_on_media_user_id", using: :btree
  add_index "point_histories", ["occurred_at"], name: "index_point_histories_on_occurred_at", using: :btree
  add_index "point_histories", ["source_type", "source_id"], name: "index_point_histories_on_source_type_and_source_id", using: :btree

  create_table "points", force: :cascade do |t|
    t.integer  "media_user_id",                null: false
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "point_type_id"
    t.integer  "point",                        null: false
    t.integer  "remains",                      null: false
    t.datetime "expiration_at"
    t.datetime "occurred_at",                  null: false
    t.boolean  "available",     default: true, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "points", ["available"], name: "index_points_on_available", using: :btree
  add_index "points", ["media_user_id"], name: "index_points_on_media_user_id", using: :btree
  add_index "points", ["occurred_at"], name: "index_points_on_occurred_at", using: :btree
  add_index "points", ["point_type_id"], name: "index_points_on_point_type_id", using: :btree
  add_index "points", ["source_type", "source_id"], name: "index_points_on_source_type_and_source_id", using: :btree

  create_table "purchases", force: :cascade do |t|
    t.integer  "media_user_id",             null: false
    t.integer  "item_id",                   null: false
    t.integer  "number",        default: 1, null: false
    t.integer  "point",                     null: false
    t.datetime "occurred_at",               null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "purchases", ["item_id"], name: "index_purchases_on_item_id", using: :btree
  add_index "purchases", ["media_user_id"], name: "index_purchases_on_media_user_id", using: :btree
  add_index "purchases", ["occurred_at"], name: "index_purchases_on_occurred_at", using: :btree

  create_table "terminal_androids", force: :cascade do |t|
    t.integer  "media_user_id",                          null: false
    t.string   "identifier",                             null: false
    t.text     "info"
    t.string   "android_version"
    t.string   "android_registration_id"
    t.boolean  "available",               default: true, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "terminal_androids", ["media_user_id"], name: "index_terminal_androids_on_media_user_id", using: :btree

end
