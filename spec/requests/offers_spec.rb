# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /api/v1/offers.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)
    offer = FactoryGirl.create(:offer, medium: medium)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/offers.json", query)

    get "/api/v1/offers.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success
  end
end
