# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

AdminUser.create(email: 'kyuuki0@gmail.com', password: '12threer')
AdminUser.create(email: 'goodx.jp@gmail.com', password: 'goodx123')

CampaignCategory.create(id: 1, name: 'アプリ DL')
CampaignCategory.create(id: 2, name: '会員登録')
CampaignCategory.create(id: 3, name: '申し込み')
CampaignCategory.create(id: 4, name: '買い物')

Medium.create(name: 'リワードアプリ（仮）', key: '6Fk810vbM3')

Network.create(id: 1, name: '自社')

