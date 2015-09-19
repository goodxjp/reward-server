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

describe 'GET /api/v1/:id/execute.json' do
  it '超正常系' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    campaign = FactoryGirl.create(:campaign)
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign, medium: medium, name: "o_name1")

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/offers/4/execute", query)

    get "/api/v1/offers/4/execute?mid=1&uid=1&sig=#{sig}"
    puts response.body
    expect(response).to redirect_to(offer.url)
  end

  it 'GREE 案件の URL 変換' do
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 1)

    campaign_source_gree = FactoryGirl.create(:campaign_source_gree)
    campaign = FactoryGirl.create(:campaign, campaign_source: campaign_source_gree)
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign, medium: medium, name: "o_name1", url: "$USER_ID$_$OFFER_ID$_$GREE_DIGEST$")

    gree_config = FactoryGirl.create(:gree_config, campaign_source: campaign_source_gree)

    query = { mid: "1", uid: "1" }
    sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", "/api/v1/offers/4/execute", query)

    get "/api/v1/offers/4/execute?mid=1&uid=1&sig=#{sig}"
    #puts response.body

    # レスポンスチェック
    digest = NetworkSystemGree.make_gree_digest_for_redirect_url(campaign, media_user)
    expect(response).to redirect_to("1_4_#{digest}")
  end
end
