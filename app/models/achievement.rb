# -*- coding: utf-8 -*-
class Achievement < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :campaign
  belongs_to :notification, polymorphic: true

  # メディアユーザーとキャンペーンを特定したあとに成果を上げる
  # - トランザクションは外部でかける
  # - メディアユーザーに対して、スレッドセーフではないので注意！
  def self.add_achievement(media_user, campaign, payment, payment_include_tax, point, occurred_at, notification)
    achievement = Achievement.new()
    achievement.media_user          = media_user
    achievement.campaign            = campaign
    achievement.payment             = payment
    achievement.payment_include_tax = payment_include_tax
    achievement.occurred_at         = occurred_at
    achievement.notification        = notification
    achievement.save!

    # 成果が上がったものは非表示にする
    Hiding.create!(media_user: media_user, target: campaign)

    # ポイント追加
    Point.add_point_by_achievement(media_user, PointType::AUTO, point, achievement)
  end

  def notification_type_name
    if notification.nil?
      return nil
    end

    # case 文でうまくかけない？
    # notification.class.kind_of?(AdcropsAchievementNotice.class) ではダメ。
    # 要調査。
    if notification.kind_of?(AdcropsAchievementNotice)
      return "adcrop"
    elsif notification.kind_of?(GreeAchievementNotice)
      return "GREE"
    else
      return "不明"
    end
  end
end
