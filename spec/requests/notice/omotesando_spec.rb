# -*- coding: utf-8 -*-
require 'rails_helper'

#
# adcrops
#
describe 'GET /notice/omotesando/adcrops' do
  it '超正常系' do
    # DB 準備
    medium = create(:medium, id: 1)
    campaign_source = create(:adcrops, id: 1)

    media_user = create(:media_user, id: 2, medium: medium)
    campaign = create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)
    click_history = create(:click_history, media_user: media_user, offer: offer)

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
    expect(achievement.payment_is_including_tax).to eq true
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
    medium = create(:medium, id: 1)
    campaign_source = create(:adcrops, id: 1)

    media_user = create(:media_user, id: 2, medium: medium)
    campaign = create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)
    click_history = create(:click_history, media_user: media_user, offer: offer)

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
    medium = create(:medium, id: 1)
    campaign_source = create(:adcrops, id: 1)

    media_user = create(:media_user, id: 2, medium: medium)
    media_user_other = create(:media_user, id: 3, medium: medium)
    campaign = create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)
    offer_other = create(:offer, id: 5, campaign: campaign, medium: medium, payment: 10)
    click_history = create(:click_history, media_user: media_user, offer: offer_other)  # 違うオファーのクリックログ
    click_history = create(:click_history, media_user: media_user_other, offer: offer)  # 違う人のクリックログ

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

  it '報酬金額が変更になった' do
    # DB 準備
    medium = FactoryGirl.create(:medium, id: 1)
    campaign_source = FactoryGirl.create(:adcrops, id: 1)

    media_user = FactoryGirl.create(:media_user, id: 2, medium: medium)
    campaign = FactoryGirl.create(:campaign, campaign_source: campaign_source, source_campaign_identifier: "3")
    offer = FactoryGirl.create(:offer, id: 4, campaign: campaign, medium: medium, payment: 5)
    click_history = FactoryGirl.create(:click_history, media_user: media_user, offer: offer)

    get "/notice/omotesando/adcrops?suid=2&xuid=7&sad=4&xad=3&cv_id=8&reward=500&point=6"
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    expect(response.body.strip).to eq ""

    # DB チェック
    achievements = Achievement.all
    expect(achievements.size).to eq 1
    achievement = achievements[0]
    expect(achievement.payment).to eq 500  # パラメータの値で報酬金額をつける

    points = Point.all
    expect(points.size).to eq 1
    point = points[0]
    expect(point.point).to eq offer.point  # オファーの値でポイントをつける
  end
end

#
# GREE
#
describe 'GET /notice/omotesando/gree' do
  before :each do
    # mid = 1, uid = 2 のデータを用意する
    prepare_for_mid_1_uid_2

    # GREE (Android) 用のキャンペーンソース
    @campaign_source = create(:campaign_source_gree, id: 2)
  end

  it '超正常系' do
    # DB 準備
    campaign = create(:campaign, campaign_source: @campaign_source, source_campaign_identifier: "3")
    offer = create(:offer, id: 4, campaign: campaign, medium: @medium, payment: 5)
    click_history = create(:click_history, media_user: @media_user, offer: offer)

    Timecop.travel(Time.zone.local(1974, 9, 24, 1, 2, 3))
    get "/notice/omotesando/gree?identifier=2&achieve_id=6&point=5&campaign_id=3&advertisement_id=7&media_session=4"
    Timecop.return
    #puts response.body
    expect(response).to be_success

    # レスポンスチェック
    expect(response.body).to eq "1"

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
    expect(achievement.payment_is_including_tax).to eq true
    expect(achievement.sales_at.to_i).to eq Time.zone.local(1974, 9, 24, 1, 2, 3).to_i  # ミリ秒対策
    expect(achievement.occurred_at.to_i).to eq Time.zone.local(1974, 9, 24, 1, 2, 3).to_i  # ミリ秒対策
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

  it '同じ achieve_id で処理済みの場合は成果を付けない' do
    # DB 準備
    campaign = create(:campaign, campaign_source: @campaign_source, source_campaign_identifier: "3")
    offer = create(:offer, id: 4, campaign: campaign, medium: @medium, payment: 5)
    click_history = create(:click_history, media_user: @media_user, offer: offer)

    # 1 回目
    get "/notice/omotesando/gree?identifier=2&achieve_id=6&point=5&campaign_id=3&advertisement_id=7&media_session=4"
    #puts response.body
    expect(response).to be_success

    # 2 回目
    get "/notice/omotesando/gree?identifier=3&achieve_id=6&point=6&campaign_id=4&advertisement_id=8&media_session=9"
    #puts response.body
    expect(response).to be_success

    # DB チェック
    notices = GreeAchievementNotice.all
    expect(notices.size).to eq 2

    achievements = Achievement.all
    expect(achievements.size).to eq 1  # 1 つしか成果がついていないこと

    points = Point.all
    expect(points.size).to eq 1
  end

  # TODO: テストで日付を自由に設定できるように (ちゃんとした、時刻のテストはしていない)
  it '同じ advertisement_id, identifier で同日の 00:00 ～ 23:59 に処理済みの場合は成果を付けない' do
    # DB 準備
    campaign = create(:campaign, campaign_source: @campaign_source, source_campaign_identifier: "3")
    offer = create(:offer, id: 4, campaign: campaign, medium: @medium, payment: 5)
    click_history = create(:click_history, media_user: @media_user, offer: offer)

    # 2 回目用のデータ
    campaign2 = create(:campaign, campaign_source: @campaign_source, source_campaign_identifier: "4")
    offer2 = create(:offer, id: 9, campaign: campaign2, medium: @medium, payment: 6)
    click_history2 = create(:click_history, media_user: @media_user, offer: offer2)

    # 1 回目
    get "/notice/omotesando/gree?identifier=2&achieve_id=6&point=5&campaign_id=3&advertisement_id=7&media_session=4"
    #puts response.body
    expect(response).to be_success
    expect(response.body).to eq "1"

    # 2 回目
    get "/notice/omotesando/gree?identifier=2&achieve_id=7&point=6&campaign_id=4&advertisement_id=7&media_session=9"
    #puts response.body
    expect(response).to be_success
    expect(response.body).to eq "0"

    # DB チェック
    notices = GreeAchievementNotice.all
    expect(notices.size).to eq 2

    achievements = Achievement.all
    expect(achievements.size).to eq 1  # 1 つしか成果がついていないこと

    points = Point.all
    expect(points.size).to eq 1
  end

  it '同じ advertisement_id, identifier で前日に処理済みの場合は成果を付ける' do
    # DB 準備
    campaign = create(:campaign, campaign_source: @campaign_source, source_campaign_identifier: "3")
    offer = create(:offer, id: 4, campaign: campaign, medium: @medium, payment: 5)
    click_history = create(:click_history, media_user: @media_user, offer: offer)

    # 2 回目用のデータ
    campaign2 = create(:campaign, campaign_source: @campaign_source, source_campaign_identifier: "4")
    offer2 = create(:offer, id: 9, campaign: campaign2, medium: @medium, payment: 6)
    click_history2 = create(:click_history, media_user: @media_user, offer: offer2)

    # 1 回目
    get "/notice/omotesando/gree?identifier=2&achieve_id=6&point=5&campaign_id=3&advertisement_id=7&media_session=4"
    #puts response.body
    expect(response).to be_success
    expect(response.body).to eq "1"

    # 受信日時を前日に変更
    notices = GreeAchievementNotice.all
    expect(notices.size).to eq 1
    #puts notices[0].created_at
    notices[0].created_at = notices[0].created_at - 1.days
    notices[0].save!

    # 2 回目
    get "/notice/omotesando/gree?identifier=2&achieve_id=7&point=6&campaign_id=4&advertisement_id=7&media_session=9"
    #puts response.body
    expect(response).to be_success
    expect(response.body).to eq "1"

    # DB チェック
    notices = GreeAchievementNotice.all
    expect(notices.size).to eq 2

    achievements = Achievement.all
    expect(achievements.size).to eq 2

    points = Point.all
    expect(points.size).to eq 2
  end

  describe '売上日時が正しく設定される' do
    # と思ったが、GREE の場合は売上日時がわかってこないのでパターンがない。
    it '売上日時は成果通知が到達した日時' do
    end
  end
end

