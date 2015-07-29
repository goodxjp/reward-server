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
    click_history = FactoryGirl.create(:click_history, media_user: media_user, offer: offer)

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

    hidings = Hiding.all
    expect(hidings.size).to eq 1
    hiding = hidings[0]
    expect(hiding.media_user.id).to eq 2
    expect(hiding.target_type).to eq "Campaign"
    expect(hiding.target.source_campaign_identifier).to eq "3"

    points = Point.all
    expect(points.size).to eq 1
    point = points[0]
    expect(point.point).to eq offer.point

    # あとは Point.add_point_by_achievement が正しいことを他の所でテスト
  end

  it '同じ cv_id で処理済みの場合は成果を付けない' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    campaign_source = FactoryGirl.create(:adcrops, id: 1)

    media_user = FactoryGirl.create(:media_user, id: 2, medium: medium)
    campaign = FactoryGirl.create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)
    click_history = FactoryGirl.create(:click_history, media_user: media_user, offer: offer)

    # 1 回目
    get "/notice/omotesando/adcrops?suid=2&xuid=7&sad=4&xad=3&cv_id=8&reward=5&point=6"
    #puts response.body
    expect(response).to be_success

    # 2 回目
    get "/notice/omotesando/adcrops?suid=2&xuid=7&sad=4&xad=3&cv_id=8&reward=5&point=6"
    #puts response.body
    expect(response).to be_success

    # DB チェック
    notices = AdcropsAchievementNotice.all
    expect(notices.size).to eq 2

    achievements = Achievement.all
    expect(achievements.size).to eq 1  # 1 つしか成果がついていないこと

    points = Point.all
    expect(points.size).to eq 1
  end

  it 'クリックログがない' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    campaign_source = FactoryGirl.create(:adcrops, id: 1)

    media_user = FactoryGirl.create(:media_user, id: 2, medium: medium)
    campaign = FactoryGirl.create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)
    click_history = FactoryGirl.create(:click_history, media_user: media_user)  # 違うオファーのクリックログ
    click_history = FactoryGirl.create(:click_history, offer: offer)  # 違う人のクリックログ

    get "/notice/omotesando/adcrops?suid=2&xuid=7&sad=4&xad=3&cv_id=8&reward=5&point=6"
    #puts response.body
    expect(response).not_to be_success

    # DB チェック
    notices = AdcropsAchievementNotice.all
    expect(notices.size).to eq 1

    achievements = Achievement.all
    expect(achievements.size).to eq 0

    points = Point.all
    expect(points.size).to eq 0
  end

  it 'キャンペーンが見つからない' do
  end

  it 'オファーが見つからない' do
  end

  it 'ユーザーが見つからない' do
  end
end

describe 'GET /notice/omotesando/gree' do
  it '超正常系' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    campaign_source = FactoryGirl.create(:campaign_source, id: 2)

    media_user = FactoryGirl.create(:media_user, id: 2, medium: medium)
    campaign = FactoryGirl.create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)
    click_history = FactoryGirl.create(:click_history, media_user: media_user, offer: offer)

    get "/notice/omotesando/gree?identifier=2&achieve_id=6&point=5&campaign_id=3&advertisement_id=7&media_session=4"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    expect(response.body.strip).to eq ""

    # DB チェック
    notices = GreeAchievementNotice.all
    expect(notices.size).to eq 1
    notice = notices[0]
    expect(notice.identifier).to eq "2"
    expect(notice.achieve_id).to eq "6"
    expect(notice.point).to eq "5"
    expect(notice.campaign_id).to eq "3"
    expect(notice.advertisement_id).to eq "7"
    expect(notice.media_session).to eq "4"

    achievements = Achievement.all
    expect(achievements.size).to eq 1
    achievement = achievements[0]
    expect(achievement.media_user.id).to eq 2
    expect(achievement.campaign.source_campaign_identifier).to eq "3"
    expect(achievement.payment).to eq 5
    expect(achievement.payment_include_tax).to eq true
    expect(achievement.occurred_at).not_to eq nil
    expect(achievement.notification).to eq notice

    hidings = Hiding.all
    expect(hidings.size).to eq 1
    hiding = hidings[0]
    expect(hiding.media_user.id).to eq 2
    expect(hiding.target_type).to eq "Campaign"
    expect(hiding.target.source_campaign_identifier).to eq "3"

    points = Point.all
    expect(points.size).to eq 1
    point = points[0]
    expect(point.point).to eq offer.point

    # あとは Point.add_point_by_achievement が正しいことを他の所でテスト
  end
end

