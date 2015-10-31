# -*- coding: utf-8 -*-
require 'rails_helper'

describe 'POST /api/v1/user.json' do
  it '超正常系' do
    medium = create(:medium, id: 1)

    query = { mid: "1", avc: "29" }
    sig = Api::V1::ApiController.make_signature(medium, nil, "POST", "/api/v1/user.json", query)

    params = { user: { terminal_id: { "id": "xxx", "version": 1, "created_at": "2015-10-09T00:06:19.445+09:00" }, terminal_info: { "a": "b", "VERSION.RELEASE": "1.0.0" }, android_registration_id: "zzz"} }
    headers = { 'CONTENT_TYPE' => 'application/json' }

    post "/api/v1/user.json?mid=1&avc=29&sig=#{sig}", params.to_json, headers
    #puts response.body
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
    expect(media_user.point).to eq 0
    expect(media_user.total_point).to eq 0
    expect(media_user.medium_id).to eq 1
    expect(media_user.key).to match(/.{10,}/)  # とりあえず、10 文字以上はあること

    media_user_updates = MediaUserUpdate.all
    expect(media_user_updates.size).to eq 1

    media_user_udpate = media_user_updates[0]
    expect(media_user_udpate.last_access_at).not_to eq nil
    expect(media_user_udpate.app_version_code).to eq 29

    terminal_androids = TerminalAndroid.all
    expect(terminal_androids.size).to eq 1

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
    medium = create(:medium, id: 1)
    media_user = create(:media_user, id: 1, point: 1000, total_point: 2000)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/user.json", query)

    get "/api/v1/user.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # TODO: DB チェック
  end
end
