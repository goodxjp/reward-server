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

  it '非表示のものは返さない' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    campaign1 = FactoryGirl.create(:campaign, name: "c_name1")
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign1, medium: medium, name: "o_name1")
    campaign2 = FactoryGirl.create(:campaign, name: "c_name2")
    offer = FactoryGirl.create(:offer, id: 40, campaign: campaign2, medium: medium, name: "o_name2")

    Hiding.create!(media_user: media_user, target: campaign2)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/offers.json", query)

    get "/api/v1/offers.json?mid=1&uid=1&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    expect(json[0]["name"]).to eq "o_name1"
  end
end
