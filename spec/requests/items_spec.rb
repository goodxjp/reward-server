# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /api/v1/items.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium)
    media_user = FactoryGirl.create(:media_user)

    query = { mid: "1", uid: "1" }
    sig = make_signature(medium, media_user, "GET", "/api/v1/items.json", query)

    item = FactoryGirl.create(:item)

    get "/api/v1/items.json?mid=1&uid=1&sig=#{sig}"
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
