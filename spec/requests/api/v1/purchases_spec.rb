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

    Timecop.travel(Time.zone.local(1974, 9, 24, 1, 2, 3))
    #puts Time.zone.now.usec
    post_purchases(1, 1, 100)
    Timecop.return
    #puts response.body
    expect(response).to be_success

    # DB チェック
    purchases = Purchase.all
    expect(purchases.size).to eq 1

    purchase = purchases[0]
    #puts purchase
    expect(purchase.media_user_id).to eq @media_user.id
    expect(purchase.item_id).to eq item.id
    expect(purchase.number).to eq 1
    expect(purchase.point).to eq 100
    #puts purchase.occurred_at.usec
    #expect(purchase.occurred_at).to eq Time.zone.local(1974, 9, 24, 1, 2, 3)
    expect(purchase.occurred_at.to_i).to eq Time.zone.local(1974, 9, 24, 1, 2, 3).to_i  # ミリ秒が違うので to_i
    # API 側で @now の値を出力したら、DB 値と一緒だったので、Timecop がミリ秒が扱えていないようだ。

    gift = Gift.find(gift.id)
    expect(gift.purchase_id).to eq purchase.id

    media_user = MediaUser.find(@media_user.id)
    expect(media_user.point).to eq 1000 - 100

    point = Point.find(point.id)
    expect(point.point).to eq 1000
    expect(point.remains).to eq 1000 - 100
    expect(point.available).to eq true
  end

  it '過去 1 時間以内に 10 万ポイント以上交換されていたらエラー' do
    item1 = create(:item, id: 1, point: 100)
    gift2 = FactoryGirl.create(:gift, item: item1)

    # 無関係のアイテムを無関係の人が購入
    item2 = create(:item, id: 2, point: 100000)
    purchase = FactoryGirl.create(:purchase,
                                  item: item2,
                                  point: 100000,
                                  occurred_at: Time.zone.local(1999, 12, 31, 23, 0, 1))
    gift2 = FactoryGirl.create(:gift, item: item2, purchase_id: purchase.id)
    # ↑実際には gift は関係ない。

    point = add_point(@media_user, 1000)

    Timecop.travel(Time.zone.local(2000, 1, 1, 0, 0, 0))
    post_purchases(1, 1, 100)
    Timecop.return
    #puts response.body
    expect(response).not_to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json["code"]).to eq 2001
  end

  it '保持ポイントが足りないときはエラー' do
    item = create(:item, id: 1, point: 100)

    post_purchases(1, 1, 100)
  end

  it '商品 ID が無効の場合はエラー' do
    item = create(:item, id: 1, point: 100,
                  available: false)
    gift = create(:gift, item: item)

    point = add_point(@media_user, 1000)

    post_purchases(1, 1, 100)
    expect(response).not_to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json["code"]).to eq 2003
  end

  it 'ポイント数が実際の商品のポイント数と異なるの場合はエラー' do
    item = create(:item, id: 1, point: 100)
    gift = create(:gift, item: item)

    point = add_point(@media_user, 1000)

    post_purchases(1, 1, 99)
    expect(response).not_to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json["code"]).to eq 2004
  end

  # 日本の時間で行っているので注意
  describe '1 日 1 回までしか購入できない' do
    before :each do
      # 購入に十分なポイントとギフト券を準備
      @item = FactoryGirl.create(:item, id: 1)
      @gift = FactoryGirl.create(:gift, item: @item, expiration_at: nil)

      @point = add_point(@media_user, 1000)
    end

    # occurred_at に購入したことにする
    def prepare_purchase(occurred_at)
      purchase = create(:purchase, media_user: @media_user, item: @item, occurred_at: occurred_at)
    end

    it 'ある日の 00:00:00 に購入済みだと当日 23:59:59 に購入できない' do
      prepare_purchase(Time.zone.local(2000, 1, 15, 0, 0, 0))

      Timecop.travel(Time.zone.local(2000, 1, 15, 23, 59, 59))
      post_purchases(1, 1, 100)
      Timecop.return

      expect(response).not_to be_success

      # レスポンスチェック
      json = JSON.parse(response.body)
      expect(json["code"]).to eq 2005
    end

    it 'ある日の 00:00:00 に購入済みだと当日 00:00:00 に購入できない' do
      prepare_purchase(Time.zone.local(2000, 1, 15, 0, 0, 0))

      Timecop.travel(Time.zone.local(2000, 1, 15, 0, 0, 0))
      post_purchases(1, 1, 100)
      Timecop.return

      expect(response).not_to be_success

      # レスポンスチェック
      json = JSON.parse(response.body)
      expect(json["code"]).to eq 2005
    end

    it 'ある日の 23:59:59 に購入済みだと当日 23:59:59 に購入できない' do
      prepare_purchase(Time.zone.local(2000, 1, 15, 23, 59, 59))

      Timecop.travel(Time.zone.local(2000, 1, 15, 23, 59, 59))
      post_purchases(1, 1, 100)
      Timecop.return

      expect(response).not_to be_success

      # レスポンスチェック
      json = JSON.parse(response.body)
      expect(json["code"]).to eq 2005
    end

    it 'ある日の 23:59:59 に購入済みだと次の日の 00:00:00 に購入できる' do
      prepare_purchase(Time.zone.local(2000, 1, 15, 23, 59, 59))

      Timecop.travel(Time.zone.local(2000, 1, 16, 0, 0, 0))
      post_purchases(1, 1, 100)
      Timecop.return

      expect(response).to be_success

      # DB チェック
      purchases = Purchase.all
      expect(purchases.size).to eq 2

      gift = Gift.find(@gift.id)
      expect(gift.purchase_id).not_to eq nil
    end

    it '去年の同日に購入済みでも次の年の同日に購入できる' do
      prepare_purchase(Time.zone.local(1999, 1, 15, 0, 0, 0))

      Timecop.travel(Time.zone.local(2000, 1, 15, 0, 0, 0))
      post_purchases(1, 1, 100)
      Timecop.return

      expect(response).to be_success

      # DB チェック
      purchases = Purchase.all
      expect(purchases.size).to eq 2

      gift = Gift.find(@gift.id)
      expect(gift.purchase_id).not_to eq nil
    end
  end

  it 'ポイントが不足している場合はエラー' do
    item = create(:item, id: 1, point: 100)
    gift = create(:gift, item: item)

    point = add_point(@media_user, 99)

    post_purchases(1, 1, 100)
    expect(response).not_to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json["code"]).to eq 2006
  end

  it '購入済みのギフトしか残っていないときはエラー' do
    item = create(:item, id: 1, point: 100)
    purchase = create(:purchase, media_user: @media_user, item: item)

    # 購入済みのギフト券
    gift = create(:gift_purchased, item: item, purchase: purchase)

    point = add_point(@media_user, 1000)

    post_purchases(1, 1, 100)
    expect(response).not_to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json["code"]).to eq 2007
  end

  it '購入されるギフト券は有効期限が古いのが優先される' do
    item = create(:item, id: 1)

    gift1 = create(:gift, item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = create(:gift, item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

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
    item = create(:item, id: 1)

    gift1 = create(:gift, item: item, expiration_at: nil)
    gift2 = create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = create(:gift, item: item, expiration_at: nil)

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

  describe 'ポイントの消費' do
    it '残ポイントが減る' do
      item = create(:item, id: 1, point: 100)
      gift = create(:gift, item: item, purchase_id: nil)

      point = create(:point, media_user: @media_user, point: 1000, remains: 800)
      @media_user.point = 800
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

    it '使用済みのポイント資産は無効になる' do
      item = create(:item, id: 1, point: 100)
      gift = create(:gift, item: item, purchase_id: nil)

      point = create(:point, media_user: @media_user, point: 1000, remains: 100)
      @media_user.point = 100
      @media_user.save

      post_purchases(1, 1, 100)
      expect(response).to be_success

      # DB チェック
      gift = Gift.find(gift.id)
      expect(gift.purchase_id).not_to eq nil

      point = Point.find(point.id)
      expect(point.remains).to eq 100 - 100
      expect(point.available).to eq false
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
      #puts response.body
      expect(response).to be_success

      # DB チェック
      gift1 = Gift.find(gift1.id)
      expect(gift1.purchase_id).not_to eq nil
      gift2 = Gift.find(gift2.id)
      expect(gift2.purchase_id).not_to eq nil

      point1 = Point.find(point1.id)
      expect(point1.remains).to eq 400 - 400
      expect(point1.available).to eq false
      point2 = Point.find(point2.id)
      expect(point2.remains).to eq 200 - 160
      expect(point2.available).to eq true
      point3 = Point.find(point3.id)
      expect(point3.remains).to eq 100 - 100
      expect(point3.available).to eq false
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
      expect(point2.available).to eq false
      point3 = Point.find(point3.id)
      expect(point3.remains).to eq 100 - 20
      expect(point3.available).to eq true
    end

    it '使用済みのポイント資産は使用されない' do
      item = create(:item, id: 1, point: 100)
      gift = create(:gift, item: item, purchase_id: nil)

      # 現実には remains が 0 より大きくて無効なポイント資産は存在しないはず (将来的にはあるかも)
      point1 = create(:point, media_user: @media_user, point: 100, remains: 100, available: false,
                      occurred_at: Time.zone.local(2000, 1, 1, 0, 0, 0))
      point2 = create(:point, media_user: @media_user, point: 100, remains: 100, available: true,
                      occurred_at: Time.zone.local(2000, 1, 2, 0, 0, 0))
      point3 = create(:point, media_user: @media_user, point: 100, remains: 100, available: false,
                      occurred_at: Time.zone.local(2000, 1, 3, 0, 0, 0))
      @media_user.point = 300
      @media_user.save

      post_purchases(1, 1, 100)
      #puts response.body
      expect(response).to be_success

      # DB チェック
      point1 = Point.find(point1.id)
      expect(point1.remains).to eq 100
      expect(point1.available).to eq false
      point2 = Point.find(point2.id)
      expect(point2.remains).to eq 100 - 100
      expect(point2.available).to eq false
      point3 = Point.find(point3.id)
      expect(point3.remains).to eq 100
      expect(point3.available).to eq false
    end

    it '有効期限の切れたポイント資産は使用されない' do
      # TODO
    end
  end
end
