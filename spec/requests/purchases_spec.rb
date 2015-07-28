# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'POST /api/v1/purchases.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    gift = FactoryGirl.create(:gift)

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "POST", "/api/v1/purchases.json", query)

    params = { item: { id: 1, number: 1, point: 100} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/purchases.json?mid=1&uid=1&sig=#{sig}", params.to_json, headers
    expect(response).to be_success

    # DB チェック
    purchases = Purchase.all
    expect(purchases.size).to eq 1

    purchase = purchases[0]
    #pp purchase
    expect(purchase.media_user_id).to eq media_user.id
    expect(purchase.item_id).to eq 1
    expect(purchase.number).to eq 1
    expect(purchase.point).to eq 100
    expect(purchase.occurred_at).not_to eq nil

    gift = Gift.find(gift.id)
    expect(gift.purchase_id).to eq purchase.id

    media_user = MediaUser.find(media_user.id)
    expect(media_user.point).to eq 1000 - 100
  end

  it '購入済みのギフトしか残っていないときはエラー' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    item = FactoryGirl.create(:item)
    purchase = FactoryGirl.create(:purchase, media_user: media_user, item: item)

    # 購入済みのギフト券
    gift = FactoryGirl.create(:gift_purchased, item: item, purchase: purchase)

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "POST", "/api/v1/purchases.json", query)

    params = { item: { id: 1, number: 1, point: 100} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/purchases.json?mid=1&uid=1&sig=#{sig}", params.to_json, headers
    expect(response).not_to be_success
  end

  it '購入されるギフト券は有効期限が古いのが優先される' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    item = FactoryGirl.create(:item)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "POST", "/api/v1/purchases.json", query)

    params = { item: { id: 1, number: 1, point: 100} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/purchases.json?mid=1&uid=1&sig=#{sig}", params.to_json, headers
    #puts response.body
    expect(response).to be_success

    # DB チェック
    gift1 = Gift.find(gift1.id)
    gift2 = Gift.find(gift2.id)
    gift3 = Gift.find(gift3.id)
    expect(gift1.purchase_id).to eq nil
    expect(gift2.purchase_id).not_to eq nil  # 有効期限が一番短いギフト券が消費される
    expect(gift3.purchase_id).to eq nil
  end

  it '購入されるギフト券は有効期限が設定されていないものが最後に使われる' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    item = FactoryGirl.create(:item)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: nil)
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: nil)

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "POST", "/api/v1/purchases.json", query)

    params = { item: { id: 1, number: 1, point: 100} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/purchases.json?mid=1&uid=1&sig=#{sig}", params.to_json, headers
    expect(response).to be_success

    # DB チェック
    gift1 = Gift.find(gift1.id)
    gift2 = Gift.find(gift2.id)
    gift3 = Gift.find(gift3.id)
    expect(gift1.purchase_id).to eq nil
    expect(gift2.purchase_id).not_to eq nil  # 有効期限が一番短いギフト券が消費される
    expect(gift3.purchase_id).to eq nil
  end

  it 'パラメータのポイントが実際の商品のポイントと違う場合はエラー' do
    # TODO
  end

  # TODO: 日付のパターンを DRY にしてもっと増やしたい
  it '1 日 1 回までしか購入ができない' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    item = FactoryGirl.create(:item)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: nil)
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: nil)
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: nil)

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")

    now = Time.zone.now
    occurred_at = Time.zone.local(now.year, now.month, now.day, 0, 0, 0)
    purchase = FactoryGirl.create(:purchase, media_user: media_user, item: item, occurred_at: occurred_at)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "POST", "/api/v1/purchases.json", query)

    params = { item: { id: 1, number: 1, point: 100} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    # 日付またぎのタイミングでやるとうまく成功しない
    # TODO: テスト時に無理やり現在日時を設定できる仕組みを
    post "/api/v1/purchases.json?mid=1&uid=1&sig=#{sig}", params.to_json, headers
    expect(response).not_to be_success
  end
end
