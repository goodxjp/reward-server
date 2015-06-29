# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /api/v1/point_histories.json' do
  it '超正常系' do
    # DB 準備
    medium = FactoryGirl.create(:medium)
    media_user = FactoryGirl.create(:media_user)
    point = FactoryGirl.create(:point, media_user: media_user)
    point_history1 = FactoryGirl.create(:point_history, media_user: media_user, point_change: 100, source: point)
    point_history2 = FactoryGirl.create(:point_history, media_user: media_user, point_change: 200, source: point)
    point_history3 = FactoryGirl.create(:point_history, media_user: media_user, point_change: 300, source: point)


    # HTTP リクエスト準備
    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/point_histories.json", query)

    get "/api/v1/point_histories.json?mid=1&uid=1&sig=#{sig}"
    puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 3
    # TODO: 内容のチェック
    # TODO: ソート順のチェック
  end
end
