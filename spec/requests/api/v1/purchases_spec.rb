# -*- coding: utf-8 -*-
require 'rails_helper'

describe 'POST /api/v1/purchases.json' do
  before :each do
    # mid = 1, uid = 1 のデータを用意する
    prepare_for_mid_1_uid_1
  end

  # ユーザーにポイントを与える
  def add_point(media_user, point_num)
    # 数字としての「ポイント数」と資産としての「ポイントオブジェクト」がいつも point で被る。
    # ポイント数を point_num にする。point_number でもいいけど number の略語は一般的だし num でいいかも。

    #Point::add_point(@media_user, PointType::MANUAL, 1000, "テスト用")
    #↑こっちの方がリアルっぽいけど、DB を完全に把握しておいた方がいいかな。point も後で使いたいし。
    point = create(:point, media_user: media_user, point: point_num, remains: point_num)
    media_user.point = point_num
    media_user.save

    return point
  end

  # mid = 1, uid = 1 で購入 API を送信
  def post_purchases(id, number, point)
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "POST", "/api/v1/purchases.json", query)

    params = { item: { id: id, number: number, point: point} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/purchases.json?mid=1&uid=1&sig=#{sig}", params.to_json, headers
  end

  it '超正常系' do
    item = create(:item, id: 1, point: 100)
    gift = create(:gift, item: item)

    point = add_point(@media_user, 1000)

    post_purchases(1, 1, 100)
    #puts response.body
    expect(response).to be_success

    # DB チェック
    purchases = Purchase.all
    expect(purchases.size).to eq 1

    purchase = purchases[0]
    #puts purchase
    expect(purchase.media_user_id).to eq @media_user.id
    expect(purchase.item_id).to eq 1
    expect(purchase.number).to eq 1
    expect(purchase.point).to eq 100
    expect(purchase.occurred_at).not_to eq nil

    gift = Gift.find(gift.id)
    expect(gift.purchase_id).to eq purchase.id

    media_user = MediaUser.find(@media_user.id)
    expect(media_user.point).to eq 1000 - 100

    point = Point.find(point.id)
    expect(point.point).to eq 1000
    expect(point.remains).to eq 1000 - 100
  end

  it '購入済みのギフトしか残っていないときはエラー' do
    item = create(:item, id: 1, point: 100)
    purchase = FactoryGirl.create(:purchase, media_user: @media_user, item: item)

    # 購入済みのギフト券
    gift = FactoryGirl.create(:gift_purchased, item: item, purchase: purchase)

    point = add_point(@media_user, 1000)

    post_purchases(1, 1, 100)
    expect(response).not_to be_success
  end

  it '購入されるギフト券は有効期限が古いのが優先される' do
    item = FactoryGirl.create(:item, id: 1)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

    point = add_point(@media_user, 1000)

    post_purchases(1, 1, 100)
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
    item = FactoryGirl.create(:item, id: 1)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: nil)
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: nil)

    point = add_point(@media_user, 1000)

    post_purchases(1, 1, 100)
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
    item = FactoryGirl.create(:item, id: 1)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: nil)
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: nil)
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: nil)

    point = add_point(@media_user, 1000)

    now = Time.zone.now
    occurred_at = Time.zone.local(now.year, now.month, now.day, 0, 0, 0)
    purchase = FactoryGirl.create(:purchase, media_user: @media_user, item: item, occurred_at: occurred_at)

    # 日付またぎのタイミングでやるとうまく成功しない
    # TODO: テスト時に無理やり現在日時を設定できる仕組みを
    post_purchases(1, 1, 100)
    expect(response).not_to be_success
  end

  describe 'ポイントの消費' do
    it '残ポイントが減る' do
      item = create(:item, id: 1, point: 100)
      gift = create(:gift, item: item, purchase_id: nil)

      point = create(:point, media_user: @media_user, point: 1000, remains: 800)
      @media_user.point = 1000
      @media_user.save

      post_purchases(1, 1, 100)
      expect(response).to be_success

      # DB チェック
      gift = Gift.find(gift.id)
      expect(gift.purchase_id).not_to eq nil

      point = Point.find(point.id)
      expect(point.remains).to eq 800 - 100
      expect(point.available).to eq true
    end

    it '複数のポイント資産が発生日時の古いものから順に使用される' do
      item = create(:item, id: 1, point: 330)
      gift1 = create(:gift, item: item, purchase_id: nil)
      gift2 = create(:gift, item: item, purchase_id: nil)

      point1 = create(:point, media_user: @media_user, point: 500, remains: 400,
                      occurred_at: Time.zone.local(2000, 1, 1, 0, 0, 0))
      point2 = create(:point, media_user: @media_user, point: 500, remains: 200,
                      occurred_at: Time.zone.local(2000, 1, 3, 0, 0, 0))
      point3 = create(:point, media_user: @media_user, point: 500, remains: 100,
                      occurred_at: Time.zone.local(2000, 1, 2, 0, 0, 0))
      @media_user.point = 1000
      @media_user.save

      post_purchases(1, 2, 660)
      expect(response).to be_success

      # DB チェック
      gift1 = Gift.find(gift1.id)
      expect(gift1.purchase_id).not_to eq nil
      gift2 = Gift.find(gift2.id)
      expect(gift2.purchase_id).not_to eq nil

      point1 = Point.find(point1.id)
      expect(point1.remains).to eq 400 - 400
      expect(point1.available).to eq true
      point2 = Point.find(point2.id)
      expect(point2.remains).to eq 200 - 160
      expect(point2.available).to eq true
      point3 = Point.find(point3.id)
      expect(point3.remains).to eq 100 - 100
      expect(point3.available).to eq true
    end

    it '複数のポイント資産が有効期限が古いものから順に使用される' do
      item = create(:item, id: 1, point: 110)
      gift1 = create(:gift, item: item, purchase_id: nil)
      gift2 = create(:gift, item: item, purchase_id: nil)

      point1 = create(:point, media_user: @media_user, point: 500, remains: 400,
                      occurred_at: Time.zone.local(2000, 1, 1, 0, 0, 0),
                      expiration_at: Time.zone.local(2100, 1, 3, 0, 0, 0))
      point2 = create(:point, media_user: @media_user, point: 500, remains: 200,
                      occurred_at: Time.zone.local(2000, 1, 3, 0, 0, 0),
                      expiration_at: Time.zone.local(2100, 1, 1, 0, 0, 0))
      point3 = create(:point, media_user: @media_user, point: 500, remains: 100,
                      occurred_at: Time.zone.local(2000, 1, 2, 0, 0, 0),
                      expiration_at: Time.zone.local(2100, 1, 2, 0, 0, 0))
      @media_user.point = 1000
      @media_user.save

      post_purchases(1, 2, 220)
      expect(response).to be_success

      # DB チェック
      gift1 = Gift.find(gift1.id)
      expect(gift1.purchase_id).not_to eq nil
      gift2 = Gift.find(gift2.id)
      expect(gift2.purchase_id).not_to eq nil

      point1 = Point.find(point1.id)
      expect(point1.remains).to eq 400 - 0
      expect(point1.available).to eq true
      point2 = Point.find(point2.id)
      expect(point2.remains).to eq 200 - 200
      expect(point2.available).to eq true
      point3 = Point.find(point3.id)
      expect(point3.remains).to eq 100 - 20
      expect(point3.available).to eq true
    end

    it '有効期限の切れたポイント資産は使用されない' do
      # TODO
    end
  end
end