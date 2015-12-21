# -*- coding: utf-8 -*-
class CreateAppDriverTables < ActiveRecord::Migration
  def change

    #
    # AppDriver
    #

    # AppDriver 成果通知
    create_table :app_driver_achievement_notices do |t|
      t.references :campaign_source, null: false, index: true

      t.string :identifier
      t.string :achieve_id
      t.string :accepted_time
      t.string :campaign_id
      t.string :campaign_name
      t.string :advertisement_id
      t.string :advertisement_name
      t.string :point
      t.string :payment

      t.timestamps null: false
    end

    add_index :app_driver_achievement_notices, [:campaign_source_id, :achieve_id], name: 'index_app_driver_achievement_notices_1'

    # AppDriver 設定
    create_table :app_driver_configs do |t|
      t.references :campaign_source, null: false, index: true

      t.integer :site_identifier, null: false
      t.string :site_key, null: false
      t.integer :media_identifier, null: false

      t.timestamps null: false
    end

    # AppDriver キャンペーン
    create_table :app_driver_campaigns do |t|
      t.references :campaign_source, null: false, index: true

      t.integer :identifier
      t.string :name
      t.text :location
      t.text :remark
      t.timestamp :start_time
      t.timestamp :end_time
      t.boolean :budget_is_unlimited
      t.text :detail
      t.text :icon
      t.text :url
      t.integer :platform
      t.integer :market
      t.integer :price
      t.integer :subscription_duration
      t.integer :remaining
      t.integer :duplication_type

      t.integer :advertisement_count
      t.integer :advertisement_identifier
      t.string :advertisement_name
      t.integer :advertisement_requisite
      t.integer :advertisement_period
      t.integer :advertisement_payment
      t.integer :advertisement_point

      t.boolean :available, default: true,  null: false, index: true
      # 有効なものだけ取り出すので index

      t.timestamps null: false
    end
  end
end
