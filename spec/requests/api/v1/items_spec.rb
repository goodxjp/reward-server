# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /api/v1/items.json' do
  it '超正常系' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)
    item = FactoryGirl.create(:item)
    gift1 = FactoryGirl.create(:gift, item: item)
    gift2 = FactoryGirl.create(:gift, item: item)
    gift3 = FactoryGirl.create(:gift, item: item)

    # HTTP リクエスト準備
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/items.json", query)

    get "/api/v1/items.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    expect(json[0]["count"]).to eq 3
  end

  it '在庫切れ' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)
    item = FactoryGirl.create(:item)
    purchase = FactoryGirl.create(:purchase, media_user: media_user, item: item)
    gift1 = FactoryGirl.create(:gift, item: item, purchase: purchase)  # 使用済みギフト券

    # HTTP リクエスト準備
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/items.json", query)

    get "/api/v1/items.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    expect(json[0]["count"]).to eq 0
  end

  it '在庫あり' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)
    item = FactoryGirl.create(:item)
    gift1 = FactoryGirl.create(:gift, item: item, purchase: nil)  # 未使用ギフト券

    # HTTP リクエスト準備
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/items.json", query)

    get "/api/v1/items.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    expect(json[0]["count"]).to eq 1
  end
end
