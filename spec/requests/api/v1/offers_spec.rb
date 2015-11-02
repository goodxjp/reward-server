# -*- coding: utf-8 -*-
require 'rails_helper'

describe 'GET /api/v1/offers.json' do
  before :each do
    # mid = 1, uid = 1 のデータを用意する
    prepare_for_mid_1_uid_1
  end

  it '超正常系' do
    offer = create(:offer, medium: @medium)

    query = { mid: "1", uid: "1", avc: "29" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "GET", "/api/v1/offers.json", query)

    get "/api/v1/offers.json?mid=1&uid=1&avc=29&sig=#{sig}"
    #puts response.body
    expect(response).to be_success
  end

  it '無効なものを返さない' do
    offer = create(:offer_unavailable, medium: @medium)

    query = { mid: "1", uid: "1", avc: "29" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "GET", "/api/v1/offers.json", query)

    get "/api/v1/offers.json?mid=1&uid=1&avc=29&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 0
  end

  it '非表示のものを返さない' do
    campaign1 = create(:campaign, name: "c_name1")
    offer1 = create(:offer, id: 4, campaign: campaign1, medium: @medium, name: "o_name1")
    campaign2 = create(:campaign, name: "c_name2")
    offer2 = create(:offer, id: 40, campaign: campaign2, medium: @medium, name: "o_name2")

    Hiding.create!(media_user: @media_user, target: campaign2)
    Hiding.create!(media_user: @media_user, target: offer1)  # 今は Offer 単位での非表示は行っていない

    query = { mid: "1", uid: "1", avc: "29" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "GET", "/api/v1/offers.json", query)

    get "/api/v1/offers.json?mid=1&uid=1&avc=29&sig=#{sig}"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    json = JSON.parse(response.body)
    expect(json.size).to eq 1
    expect(json[0]["name"]).to eq "o_name1"
  end
end

describe 'GET /api/v1/:id/execute.json' do
  before :each do
    # mid = 1, uid = 1 のデータを用意する
    @medium = create(:medium, id: 1)
    @media_user = create(:media_user, id: 1, medium: @medium)
  end

  it '超正常系' do
    campaign = create(:campaign)
    offer = create(:offer, id: 4, campaign: campaign, medium: @medium, name: "o_name1")

    query = { mid: "1", uid: "1", avc: "29" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "GET", "/api/v1/offers/4/execute", query)

    get "/api/v1/offers/4/execute?mid=1&uid=1&avc=29&sig=#{sig}"
    #puts response.body
    expect(response).to redirect_to(offer.url)
  end

  it 'GREE 案件の URL が変換されている' do
    campaign_source_gree = create(:campaign_source_gree)
    gree_config = create(:gree_config, campaign_source: campaign_source_gree)

    campaign = create(:campaign, campaign_source: campaign_source_gree)
    offer = create(:offer, id: 4, campaign: campaign, medium: @medium, name: "o_name1", url: "$USER_ID$_$OFFER_ID$_$GREE_DIGEST$")

    query = { mid: "1", uid: "1", avc: "29" }
    sig = Api::V1::ApiController.make_signature(@medium, @media_user, "GET", "/api/v1/offers/4/execute", query)

    get "/api/v1/offers/4/execute?mid=1&uid=1&avc=29&sig=#{sig}"
    #puts response.body

    # レスポンスチェック
    digest = NetworkSystemGree.make_gree_digest_for_redirect_url(campaign, @media_user)
    expect(response).to redirect_to("1_4_#{digest}")
  end
end
