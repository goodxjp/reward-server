# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /api/v1/gifts.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium)
    media_user = FactoryGirl.create(:media_user)

    query = { mid: "1", uid: "1" }
    sig = make_signature(medium, media_user, "GET", "/api/v1/gifts.json", query)

    item = FactoryGirl.create(:item)

    gift1 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2008-02-10 15:30:45'))
    gift2 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2007-02-10 15:30:45'))
    gift3 = FactoryGirl.create(:gift, item: item, expiration_at: Time.zone.parse('2009-02-10 15:30:45'))

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")
    Purchase::purchase(media_user, item, 1, 100)

    get "/api/v1/gifts.json?mid=1&uid=1&sig=#{sig}"
    pp response.body
    expect(response).to be_success
  end

  # TODO: RSpec 内共通化
  # TODO: Rails と共通化
  # 署名作成
  def make_signature(medium, media_user, method, path, query)
    sorted_query = query.sort
    sorted_query_array = []
    sorted_query.each do |i|
      sorted_query_array << i.join('=')
    end
    sorted_query_string = sorted_query_array.join('&')

    key = "#{medium.key}&#{media_user.terminal_id}"
    data = "#{method}\n#{path}\n#{sorted_query_string}"

    correct_sig = OpenSSL::HMAC.hexdigest('sha1', key, data)

    return correct_sig
  end
end
