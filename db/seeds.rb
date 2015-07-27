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

#
# メディア
# - ID は成果通知のコードとあわせる必要あり。
#
medium = Medium.find_or_create_by(id: 1)
medium.name = 'リワードアプリ (仮)'
medium.key = '6Fk810vbM3'
medium.save!

if Network.count == 0
  Network.create(id: 1, name: '自社')
  Network.create(id: 2, name: '8crops')
end

#
# キャンペーンソース
# - ID は成果通知のコードとあわせる必要あり。
#
campaign_source = CampaignSource.find_or_create_by(id: 1)
campaign_source.network_system = NetworkSystem::ADCROPS
campaign_source.name = "adcrops (一つ目のメディア)"
campaign_source.network_id = 2
campaign_source.save!

campaign_source = CampaignSource.find_or_create_by(id: 2)
campaign_source.network_system = NetworkSystem::GREE
campaign_source.name = "GREE (一つ目のメディア)"
campaign_source.network_id = 2
campaign_source.save!

campaign_source = CampaignSource.find_or_create_by(id: 3)
campaign_source.network_system = NetworkSystem::ADCROPS
campaign_source.name = "adcrops (Reward Pro)"
campaign_source.network_id = 2
campaign_source.save!

if Item.find_by(id: 1) == nil
  Item.create(id: 1, name: 'Amazon ギフト券 (100 円分)', point: 100)
end
if Item.find_by(id: 2) == nil
  Item.create(id: 2, name: 'Amazon ギフト券 (500 円分)', point: 500)
end
if Item.find_by(id: 3) == nil
  Item.create(id: 3, name: 'Amazon ギフト券 (1000 円分)', point: 950)
end

