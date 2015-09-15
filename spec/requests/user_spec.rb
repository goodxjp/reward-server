# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'POST /api/v1/user.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium, id: 1)

    query = { mid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, nil, "POST", "/api/v1/user.json", query)

    params = { user: { terminal_id: "xxx", terminal_info: { "a": "b", "VERSION.RELEASE": "1.0.0" }, android_registration_id: "zzz"} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/user.json?mid=1&sig=#{sig}", params.to_json, headers
    #pp response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json["id"]).not_to eq nil
    expect(json["key"]).to match(/.{10,}/)  # とりあえず、10 文字以上はあること
    expect(json["point"]).to eq 0

    # DB チェック
    media_users = MediaUser.all
    expect(media_users.size).to eq 1

    media_user = media_users[0]
    expect(media_user.terminal_id).to eq "xxx"
    expect(media_user.android_registration_id).to eq "zzz"

    terminal_androids = TerminalAndroid.all
    expect(terminal_androids.size).to eq 1

    json = JSON.parse(media_user.terminal_info)
    expect(json["a"]).to eq "b"

    terminal_android = terminal_androids[0]
    expect(terminal_android.media_user).to eq media_user
    expect(terminal_android.identifier).to eq "xxx"
    expect(terminal_android.android_version).to eq "1.0.0"
    expect(terminal_android.android_registration_id).to eq "zzz"

    json = JSON.parse(terminal_android.info)
    expect(json["a"]).to eq "b"
    expect(json["VERSION.RELEASE"]).to eq "1.0.0"
  end
end

describe 'GET /api/v1/user.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/user.json", query)

    Point::add_point(media_user, PointType::MANUAL, 1000, "テスト用")

    get "/api/v1/user.json?mid=1&uid=1&sig=#{sig}"
    #pp response.body
    expect(response).to be_success
  end
end
