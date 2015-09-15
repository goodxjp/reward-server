# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if AdminUser.count == 0
  AdminUser.create(email: 'kyuuki0@gmail.com', password: '12threer')
  AdminUser.create(email: 'goodx.jp@gmail.com', password: 'goodx123')
end

#
# キャンペーンカテゴリ
#
if CampaignCategory.find_by(id: 1) == nil
  CampaignCategory.create(id: 1, name: 'アプリ DL')
end
if CampaignCategory.find_by(id: 2) == nil
  CampaignCategory.create(id: 2, name: '会員登録')
end
if CampaignCategory.find_by(id: 3) == nil
  CampaignCategory.create(id: 3, name: '申し込み')
end
if CampaignCategory.find_by(id: 4) == nil
  CampaignCategory.create(id: 4, name: '買い物')
end

# PostgreSQL 依存
ActiveRecord::Base.connection.execute("SELECT setval('campaign_categories_id_seq', coalesce((SELECT MAX(id)+1 FROM campaign_categories), 1), false)")

#
# メディア
# - ID は成果通知のコードとあわせる必要あり。
#
# まだ、確定していないので毎回変更してしまう。
medium = Medium.find_or_create_by(id: 1)
medium.media_type = MediaType::ANDROID
medium.name = 'リワードアプリ (仮)'
medium.key = '6Fk810vbM3'
medium.save!

# PostgreSQL 依存
ActiveRecord::Base.connection.execute("SELECT setval('media_id_seq', coalesce((SELECT MAX(id)+1 FROM media), 1), false)")

#
# ネットワーク
#
if Network.find_by(id: 1) == nil
  Network.create(id: 1, name: '自社')
end
if Network.find_by(id: 2) == nil
  Network.create(id: 2, name: '8crops')
end
if Network.find_by(id: 3) == nil
  Network.create(id: 3, name: 'Glossom')
end

# PostgreSQL 依存
ActiveRecord::Base.connection.execute("SELECT setval('networks_id_seq', coalesce((SELECT MAX(id)+1 FROM networks), 1), false)")

#
# キャンペーンソース
# - ID は成果通知のコードとあわせる必要あり。
# - キャンペーンソースは手動で ID を決める必要があるので、シーケンスのリセットはしない
#
campaign_source = CampaignSource.find_or_create_by(id: 1)
campaign_source.network_system = NetworkSystem::ADCROPS
campaign_source.name = "adcrops (Android)"
campaign_source.network_id = 2
campaign_source.save!

campaign_source = CampaignSource.find_or_create_by(id: 2)
campaign_source.network_system = NetworkSystem::GREE
campaign_source.name = "GREE (Android)"
campaign_source.network_id = 3
campaign_source.save!

if GreeConfig.find_by(campaign_source: campaign_source) == nil
  # テスト環境用
  GreeConfig.create(campaign_source: campaign_source,
                     media_identifier: 1318,
                     site_key: "e77aa5facba56d6c331bb5a827705f18")
end

# 複数メディアの検証用
campaign_source = CampaignSource.find_or_create_by(id: 3)
campaign_source.network_system = NetworkSystem::ADCROPS
campaign_source.name = "adcrops (Reward Pro)"
campaign_source.network_id = 2
campaign_source.save!

#
# 商品
#
if Item.find_by(id: 1) == nil
  Item.create(id: 1, name: 'Amazon ギフト券 (100 円分)', point: 100)
end
if Item.find_by(id: 2) == nil
  Item.create(id: 2, name: 'Amazon ギフト券 (500 円分)', point: 500)
end
if Item.find_by(id: 3) == nil
  Item.create(id: 3, name: 'Amazon ギフト券 (1000 円分)', point: 950)
end

# PostgreSQL 依存
ActiveRecord::Base.connection.execute("SELECT setval('items_id_seq', coalesce((SELECT MAX(id)+1 FROM items), 1), false)")

