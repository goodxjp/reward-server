# -*- coding: utf-8 -*-
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  describe '.add_achievement' do
    example '超正常系' do
      media_user = FactoryGirl.create(:media_user, point: 10, total_point: 20)
      campaign = FactoryGirl.create(:campaign)

      Achievement.add_achievement(media_user, campaign, 0, false, 100, Time.zone.local(2000, 1, 2, 3, 4, 5))

      achievements = Achievement.all
      expect(achievements.size).to eq 1
      achievement = achievements[0]
      expect(achievement.notification).to eq nil
      expect(achievement.media_user).to eq media_user
      expect(achievement.campaign).to eq campaign
      expect(achievement.payment).to eq 0
      expect(achievement.payment_is_including_tax).to eq false
      expect(achievement.sales_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)
      expect(achievement.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)

      hidings = Hiding.all
      expect(hidings.size).to eq 1
      hiding = hidings[0]
      expect(hiding.media_user).to eq media_user
      expect(hiding.target).to eq campaign

      # 以下は Point.add_point_by_achievement のテストで実施
      points = Point.all
      expect(points.size).to eq 1
      point = points[0]
      expect(point.media_user).to eq media_user
      expect(point.point_type).to eq PointType::AUTO
      expect(point.source).to eq achievement
      expect(point.point).to eq 100
      expect(point.remains).to eq 100
      expect(point.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)
      # 有効期限とかは Point.add_point_by_achievement でテスト
      expect(point.available).to eq true

      point_histories = PointHistory.all
      expect(point_histories.size).to eq 1
      point_history = point_histories[0]
      expect(point_history.media_user).to eq media_user
      expect(point_history.point_change).to eq 100
      expect(point_history.detail).to eq campaign.name
      expect(point_history.source).to eq achievement
      expect(point_history.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)

      expect(media_user.point).to eq 10 + 100
      expect(media_user.total_point).to eq 20 + 100
    end

    it '売上日が正しく保存される' do
      media_user = FactoryGirl.create(:media_user, point: 10, total_point: 20)
      campaign = FactoryGirl.create(:campaign)

      Achievement.add_achievement(media_user, campaign, 0, false, 100, Time.zone.local(2000, 1, 2, 3, 4, 5),
                                   sales_at: Time.zone.local(2020, 1, 1, 0, 0, 0))

      achievement = Achievement.first
      expect(achievement.sales_at).to eq Time.zone.local(2020, 1, 1, 0, 0, 0)
      expect(achievement.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)

      point = Point.first
      expect(point.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)

      point_history = PointHistory.first
      expect(point_history.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)
    end

    it '通知が正しく保存される' do
      media_user = FactoryGirl.create(:media_user, point: 10, total_point: 20)
      campaign = FactoryGirl.create(:campaign)
      notification = FactoryGirl.create(:app_driver_achievement_notice)

      Achievement.add_achievement(media_user, campaign, 0, false, 100, Time.zone.local(2000, 1, 2, 3, 4, 5),
                                   notification: notification)

      achievement = Achievement.first
      expect(achievement.notification).to eq notification
      expect(achievement.sales_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)
      expect(achievement.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)

      point = Point.first
      expect(point.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)

      point_history = PointHistory.first
      expect(point_history.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)
    end

    it 'ポイント種別が正しく保存される' do
      media_user = FactoryGirl.create(:media_user, point: 10, total_point: 20)
      campaign = FactoryGirl.create(:campaign)

      Achievement.add_achievement(media_user, campaign, 0, false, 100, Time.zone.local(2000, 1, 2, 3, 4, 5),
                                   point_type: PointType::MANUAL)

      achievement = Achievement.first
      expect(achievement.sales_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)
      expect(achievement.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)

      point = Point.first
      expect(point.point_type).to eq PointType::MANUAL
      expect(point.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)

      point_history = PointHistory.first
      expect(point_history.occurred_at).to eq Time.zone.local(2000, 1, 2, 3, 4, 5)
    end
  end
end
