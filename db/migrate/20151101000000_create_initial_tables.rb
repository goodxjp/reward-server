# -*- coding: utf-8 -*-
class CreateInitialTables < ActiveRecord::Migration
  def change
    # メディア
    create_table :media do |t|
      t.references :media_type

      t.string :name, null: false
      t.string :key, null: false

      t.integer :at_least_app_version_code

      t.timestamps null: false
    end

    # メディアユーザー
    create_table :media_users do |t|
      t.references :medium, null: false, index: true
      t.string :key, null: false, limit: 16
      t.integer :point, default: 0, null: false
      t.integer :total_point, default: 0, null: false

      t.boolean :available, default: true,  null: false

      t.timestamps null: false
    end

    # メディアユーザー更新情報
    create_table :media_user_updates do |t|
      t.references :media_user, null: false, index: true
      t.datetime :last_access_at, null: false
      t.integer :app_version_code, null: false

      t.timestamps null: false
    end

    # 端末情報 (Android)
    create_table :terminal_androids do |t|
      t.references :media_user, null: false, index: true

      t.string :identifier, null: false
      t.text :info
      t.string :android_version
      t.string :android_registration_id

      t.boolean :available, default: true,  null: false

      t.timestamps null: false
    end

    # ネットワーク
    create_table :networks do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    # キャンペーンソース
    create_table :campaign_sources do |t|
      t.references :network_system, null: false, index: true
      # デフォルトの network。実際にはキャンペーンにある network が使われる。
      t.references :network, null: false, index: true

      t.string :name, null: false

      t.timestamps null: false
    end

    # キャンペーンカテゴリ
    create_table :campaign_categories do |t|
      t.string :name, null: false

      t.timestamps null: false
    end

    # キャンペーン
    create_table :campaigns do |t|
      t.references :network, null: false, index: true
      t.references :campaign_source, index: true
      t.references :source, polymorphic: true, index: true
      t.string :source_campaign_identifier

      t.references :campaign_category, index: true
      t.string :name, null: false
      t.text :detail
      # http://xoyip.hatenablog.com/entry/2014/07/08/200000
      t.text :icon_url
      t.text :url, null: false
      t.string :requirement
      t.text :requirement_detail
      t.string :period
      t.integer :price, default:0, null: false
      t.integer :payment, null: false
      t.boolean :payment_is_including_tax, default: false, null: false
      t.integer :point

      t.boolean :available, default: true,  null: false

      t.timestamps null: false
    end

    # キャンペーンとメディアの中間テーブル
    create_table :campaigns_media, id: false do |t|
      t.references :campaign, null: false, index: true
      t.references :medium, null: false, index: true
    end

    # オファー
    create_table :offers do |t|
      t.references  :campaign, null: false, index: true
      t.references :medium, null: false, index: true

      t.references :campaign_category, index: true
      t.string :name, null: false
      t.text :detail
      t.text :icon_url
      t.text :url, null: false
      t.string :requirement
      t.text :requirement_detail
      t.string :period
      t.integer :price, default:0, null: false
      t.integer :payment, null: false
      t.boolean :payment_is_including_tax, default: false, null: false
      t.integer :point, null: false  # ここだけ campaign と異なる

      t.boolean :available, default: true,  null: false

      t.timestamps null: false
    end

    # 非表示
    create_table :hidings do |t|
      t.references :media_user, null: false, index: true
      t.references :target, polymorphic: true, null: false, index: true

      t.timestamps null: false
    end

    # クリック履歴
    create_table :click_histories do |t|
      t.references :media_user, null: false, index: true
      t.references :offer, null: false, index: true
      t.text :request_info
      # http://blog.livedoor.jp/nipotan/archives/51195204.html
      t.string :ip_address, limit: 45

      t.timestamps null: false
    end

    # 成果
    create_table :achievements do |t|
      t.references :notification, polymorphic: true, index: true
      t.references :media_user, index: true  # ユーザーのない成果はありうる
      t.references :campaign, index: true  # キャンペーンの特定できない成果もでてきそう

      t.integer :payment, null: false
      t.boolean :payment_is_including_tax, default: false, null: false

      t.datetime :sales_at, null: false, index: true
      t.datetime :occurred_at, null: false, index: true

      t.timestamps null: false
    end

    # ポイント資産
    create_table :points do |t|
      t.references :media_user, null: false, index: true
      t.references :source, polymorphic: true, index: true

      t.references :point_type, index: true
      t.integer :point, null: false
      t.integer :remains, null: false
      t.datetime :expiration_at
      t.datetime :occurred_at, null: false, index: true

      t.boolean :available, default: true,  null: false, index: true

      t.timestamps null: false
    end

    # ポイント履歴
    create_table :point_histories do |t|
      t.references :media_user, null: false, index: true
      t.references :source, polymorphic: true, index: true

      t.integer :point_change
      t.string :detail
      t.datetime :occurred_at, null: false, index: true

      t.timestamps null: false
    end

    # 商品
    create_table :items do |t|
      t.string :name, null: false
      t.integer :point, null: false

      t.boolean :available, default: true,  null: false

      t.timestamps null: false
    end

    # ギフト券
    create_table :gifts do |t|
      t.references :item, null: false, index: true
      t.references :purchase, index: true

      t.string :code, null: false
      t.datetime :expiration_at

      t.timestamps null: false
    end

    # 購入
    create_table :purchases do |t|
      t.references :media_user, null: false, index: true
      t.references :item, null: false, index: true

      t.integer :number, default: 1, null: false
      t.integer :point, null: false
      t.datetime :occurred_at, null: false, index: true

      t.timestamps null: false
    end

    #
    # adcrops
    #
    create_table :adcrops_achievement_notices do |t|
      t.references :campaign_source, index: true

      t.string :suid
      t.string :xuid
      t.string :sad
      t.string :xad
      t.string :cv_id
      t.string :reward
      t.string :point

      t.timestamps null: false
    end

    add_index "adcrops_achievement_notices", ["campaign_source_id", "cv_id"], name: "index_adcrops_achievement_notices_1", using: :btree

    #
    # GREE (GREE Ads Reward)
    #

    # GREE 成果通知
    create_table :gree_achievement_notices do |t|
      t.references :campaign_source, index: true

      t.string :identifier
      t.string :achieve_id
      t.string :point
      t.string :campaign_id
      t.string :advertisement_id
      t.string :media_session

      t.timestamps null: false
    end

    add_index :gree_achievement_notices, [:campaign_source_id, :achieve_id], name: 'index_gree_achievement_notices_1'
    add_index :gree_achievement_notices, [:campaign_source_id, :identifier, :advertisement_id], name: 'index_gree_achievement_notices_2'

    # GREE 設定
    create_table :gree_configs do |t|
      t.references :campaign_source, index: true

      t.integer  :media_identifier, null: false
      t.string :site_key, null: false

      t.timestamps null: false
    end

    # 管理ユーザー (Devise)
    create_table(:admin_users) do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :admin_users, :email,                unique: true
    add_index :admin_users, :reset_password_token, unique: true
    # add_index :admin_users, :confirmation_token,   unique: true
    # add_index :admin_users, :unlock_token,         unique: true

    # 設定
    create_table :configs do |t|
      t.timestamps null: false
    end
  end
end
