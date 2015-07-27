# -*- coding: utf-8 -*-
require 'rails_helper'
require 'pp'

describe 'GET /notice/omotesando/adcrops' do
  it '超正常系' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    campaign_source = FactoryGirl.create(:adcrops, id: 1)

    media_user = FactoryGirl.create(:media_user, id: 2, medium: medium)
    campaign = FactoryGirl.create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)

    get "/notice/omotesando/adcrops?suid=2&xuid=7&sad=4&xad=3&cv_id=8&reward=5&point=6"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    expect(response.body.strip).to eq ""

    # DB チェック
    notices = AdcropsAchievementNotice.all
    expect(notices.size).to eq 1
    notice = notices[0]
    expect(notice.suid).to eq "2"
    expect(notice.xuid).to eq "7"
    expect(notice.sad).to eq "4"
    expect(notice.xad).to eq "3"
    expect(notice.cv_id).to eq "8"
    expect(notice.reward).to eq "5"
    expect(notice.point).to eq "6"

    achievements = Achievement.all
    expect(achievements.size).to eq 1
    achievement = achievements[0]
    expect(achievement.media_user.id).to eq 2
    expect(achievement.campaign.source_campaign_identifier).to eq "3"
    expect(achievement.payment).to eq 5
    expect(achievement.payment_include_tax).to eq true
    expect(achievement.occurred_at).not_to eq nil
    expect(achievement.notification).to eq notice

    points = Point.all
    expect(points.size).to eq 1
    point = points[0]
    expect(point.point).to eq offer.point

    # あとは Point.add_point_by_achievement が正しいことを他の所でテスト
  end

  it 'キャンペーンが見つからない' do
  end

  it 'オファーが見つからない' do
  end

  it 'ユーザーが見つからない' do
  end
end
