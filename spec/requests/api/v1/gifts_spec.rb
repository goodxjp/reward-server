# -*- coding: utf-8 -*-
require 'rails_helper'

describe 'GET /api/v1/gifts.json' do
  before :each do
    # mid = 1, uid = 1 のデータを用意する
    prepare_for_mid_1_uid_1
  end

  it '超正常系' do
    # DB 準備
    item = create(:item, point: 100)
    gift = create(:gift, item: item, expiration_at: Time.zone.local(2100, 1, 1, 0, 0, 0))

    add_point(@media_user, 1000)
    Purchase::purchase(@media_user, item, 1, 100, Time.zone.local(2000, 9, 1, 0, 0, 0))

    # HTTP リクエスト準備
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "GET", "/api/v1/gifts.json", query)

    get "/api/v1/gifts.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    expect(json[0]["name"]).to eq item.name
    expect(json[0]["code"]).to eq gift.code
    expect(Time.zone.parse(json[0]["expiration_at"])).to eq Time.zone.local(2100, 1, 1, 0, 0, 0)
    expect(Time.zone.parse(json[0]["occurred_at"])).to eq Time.zone.local(2000, 9, 1, 0, 0, 0)
  end

  it '他の人のギフト券は返さない' do
    # DB 準備
    media_user_other = create(:media_user, medium: @medium)

    item = create(:item)
    gift1 = create(:gift, code: "GIFT1XXXXX", item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = create(:gift, code: "GIFT2XXXXX", item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = create(:gift, code: "GIFT3XXXXX", item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

    add_point(@media_user, 1000)
    add_point(media_user_other, 1000)
    Purchase::purchase(@media_user, item, 1, 100, Time.zone.now)  # gift2 の使われるはず
    Purchase::purchase(media_user_other, item, 1, 100, Time.zone.now)  # gift3 が使われるはず

    # HTTP リクエスト準備
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "GET", "/api/v1/gifts.json", query)

    get "/api/v1/gifts.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    expect(json[0]["code"]).to eq "GIFT2XXXXX"
  end
end
