# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /notice/media/[:media_id]/adcrops' do
  it '超正常系' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    media_user = FactoryGirl.create(:media_user, id: 2, medium: medium)
    campaign_source = FactoryGirl.create(:adcrops, id: 2)
    campaign = FactoryGirl.create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)

    get "/notice/media/1/adcrops?suid=2&xuid=1&sad=4&xad=3&cv_id=1&reward=5&point=6"
    puts response.body
    expect(response).to be_success
  end

  it 'メディアが見つからない' do
  end

  it 'キャンペーンが見つからない' do
  end

  it 'オファーが見つからない' do
  end

  it 'ユーザーが見つからない' do
  end
end
