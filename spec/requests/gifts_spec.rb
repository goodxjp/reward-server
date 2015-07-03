# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /api/v1/gifts.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium)
    media_user = FactoryGirl.create(:media_user)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/gifts.json", query)

    item = FactoryGirl.create(:item)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")
    Purchase::purchase(media_user, item, 1, 100, Time.zone.now)

    get "/api/v1/gifts.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success
  end

  # TODO: できてなくね？
  it '他の人のギフト券は返さない' do
    medium = FactoryGirl.create(:medium)
    media_user = FactoryGirl.create(:media_user)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/gifts.json", query)

    item = FactoryGirl.create(:item)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")
    Purchase::purchase(media_user, item, 1, 100, Time.zone.now)

    get "/api/v1/gifts.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success
  end

end
