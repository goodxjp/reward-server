# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'POST /api/v1/user.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium)

    query = { mid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "POST", "/api/v1/user.json", query)

    params = { item: { id: 1, number: 1, point: 100} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/user.json?mid=1&sig=#{sig}", params.to_json, headers
    pp response.body
    expect(response).to be_success
  end
end

describe 'GET /api/v1/user.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium)
    media_user = FactoryGirl.create(:media_user)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/user.json", query)

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")

    get "/api/v1/user.json?mid=1&uid=1&sig=#{sig}"
    pp response.body
    expect(response).to be_success
  end
end
