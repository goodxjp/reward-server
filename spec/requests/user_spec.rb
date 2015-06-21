# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'POST /api/v1/user.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium)

    query = { mid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, nil, "POST", "/api/v1/user.json", query)

    params = { user: { terminal_id: "xxx", terminal_info: { "a" => "b" }, android_registration_id: "zzz"} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/user.json?mid=1&sig=#{sig}", params.to_json, headers
    #pp response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json["id"]).not_to eq nil
    expect(json["point"]).to eq 0

    # DB チェック
    media_users = MediaUser.all
    expect(media_users.size).to eq 1

    media_user = media_users[0]
    expect(media_user.terminal_id).to eq "xxx"
    expect(media_user.android_registration_id).to eq "zzz"

    json = JSON.parse(media_user.terminal_info)
    expect(json["a"]).to eq "b"
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
    #pp response.body
    expect(response).to be_success
  end
end
