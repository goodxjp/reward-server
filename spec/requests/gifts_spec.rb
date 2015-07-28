# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /api/v1/gifts.json' do
  it '超正常系' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    item = FactoryGirl.create(:item)
    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")
    Purchase::purchase(media_user, item, 1, 100, Time.zone.now)

    # HTTP リクエスト準備
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/gifts.json", query)

    get "/api/v1/gifts.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success
  end

  it '他の人のギフト券は返さない' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1, medium: medium, terminal_id: "xxx")
    media_user_other = FactoryGirl.create(:media_user, medium: medium, terminal_id: "yyy")

    item = FactoryGirl.create(:item)
    gift1 = FactoryGirl.create(:gift, code: "GIFT1XXXXX", item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = FactoryGirl.create(:gift, code: "GIFT2XXXXX", item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, code: "GIFT3XXXXX", item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")
    Point::add_point(media_user_other, PointType::MANUAL, 1000, "テスト用")
    Purchase::purchase(media_user, item, 1, 100, Time.zone.now)  # gift2 の使われるはず
    Purchase::purchase(media_user_other, item, 1, 100, Time.zone.now)  # gift3 が使われるはず

    # HTTP リクエスト準備
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/gifts.json", query)

    get "/api/v1/gifts.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    expect(json[0]["code"]).to eq "GIFT2XXXXX"

    # DB チェック
  end
end
