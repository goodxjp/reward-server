# -*- coding: utf-8 -*-
require 'rails_helper'

describe 'GET /api/v1/point_histories.json' do
  before :each do
    # mid = 1, uid = 1 のデータを用意する
    prepare_for_mid_1_uid_1
  end

  it '超正常系' do
    # DB 準備
    point = create(:point, media_user: @media_user)
    point_history1 = create(:point_history, media_user: @media_user,
                            point_change: 100,
                            detail: "detail_1",
                            source: point,
                            occurred_at: Time.zone.local(2001, 1, 1, 0, 0, 0))
    point_history2 = create(:point_history, media_user: @media_user,
                            point_change: 200,
                            detail: "detail_2",
                            source: point,
                            occurred_at: Time.zone.local(2002, 1, 1, 0, 0, 0))
    point_history3 = create(:point_history, media_user: @media_user,
                            point_change: 300,
                            detail: "detail_3",
                            source: point,
                            occurred_at: Time.zone.local(2000, 1, 1, 0, 0, 0))

    # HTTP リクエスト準備
    query = { mid: "1", uid: "1", avc: "29" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "GET", "/api/v1/point_histories.json", query)

    get "/api/v1/point_histories.json?mid=1&uid=1&avc=29&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 3

    # 新しいものが一番最初
    expect(json[0]["detail"]).to eq point_history2.detail
    expect(json[0]["point_change"]).to eq point_history2.point_change
    expect(Time.zone.parse(json[0]["occurred_at"])).to eq point_history2.occurred_at
    # 文字列でチェックしておいた方がよさそう
    expect(json[0]["occurred_at"]).to eq "2002-01-01T00:00:00.000+09:00"

    expect(json[1]["detail"]).to eq point_history1.detail
    expect(json[2]["detail"]).to eq point_history3.detail
  end
end
