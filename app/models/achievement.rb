# -*- coding: utf-8 -*-
class Achievement < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :campaign
  belongs_to :notification, polymorphic: true

  # メディアユーザーとキャンペーンを特定したあとに成果を上げる
  # - トランザクションは外部でかける
  # - メディアユーザーに対して、スレッドセーフではないので注意！
  def self.add_achievement(media_user, campaign, payment, payment_include_tax, point, occurred_at, notification)
    # TODO: クリック履歴があるかどうかチェック

    achievement = Achievement.new()
    achievement.media_user          = media_user
    achievement.campaign            = campaign
    achievement.payment             = payment
    achievement.payment_include_tax = payment_include_tax
    achievement.occurred_at         = occurred_at
    achievement.notification        = notification
    achievement.save!

    Point.add_point_by_achievement(media_user, PointType::AUTO, point, achievement)
  end
end
