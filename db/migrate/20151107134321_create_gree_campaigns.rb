# -*- coding: utf-8 -*-
class CreateGreeCampaigns < ActiveRecord::Migration
  def change
    # GREE キャンペーン
    create_table :gree_campaigns do |t|
      t.references :campaign_source, null: false, index: true

      t.integer :site_price
      t.string :icon_url

      t.integer :thanks_count
      t.integer :thanks_media_revenue
      t.string :thanks_thanks_name
      t.integer :thanks_thanks_point
      t.integer :thanks_thanks_category
      t.integer :thanks_thanks_period

      t.integer :campaign_identifier
      t.integer :subscription_duration
      t.string :carrier
      t.timestamp :start_time
      t.timestamp :end_time
      t.integer :is_url_scheme
      t.string :site_price_currency
      t.text :site_description
      t.string :site_name
      t.integer :campaign_category
      t.string :market_app_id
      t.string :click_url
      t.string :default_thanks_name
      t.integer :number_of_max_action_daily
      t.integer :daily_action_left_in_stock
      t.integer :number_of_max_action
      t.text :draft
      t.integer :platform_identifier
      t.integer :duplication_type
      t.string :duplication_date

      t.boolean :available, default: true,  null: false, index: true
      # 有効なものだけ取り出すので index

      t.timestamps null: false
    end
  end
end
