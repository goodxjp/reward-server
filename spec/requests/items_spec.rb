# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /api/v1/items.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium)
    media_user = FactoryGirl.create(:media_user)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/items.json", query)

    item = FactoryGirl.create(:item)

    get "/api/v1/items.json?mid=1&uid=1&sig=#{sig}"
    expect(response).to be_success
  end
end
