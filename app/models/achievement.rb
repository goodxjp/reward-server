# -*- coding: utf-8 -*-
class Achievement < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :campaign
  belongs_to :notification, polymorphic: true

  has_many :points, as: :source

  #
  # メディアユーザーとキャンペーンを特定した後に成果を上げる (売上日時がない場合)
  #
  # * トランザクションは外部でかけること
  # * メディアユーザーに対して、スレッドセーフではないので注意！
  #
  def self.add_achievement(media_user, campaign, payment, payment_is_including_tax, point,
                           occurred_at, notification, point_type = PointType::AUTO)
    achievement = Achievement.create!(media_user: media_user,
                                      campaign: campaign,
                                      payment: payment,
                                      payment_is_including_tax: payment_is_including_tax,
                                      # 売上日時が成果通知で渡ってこない場合は発生日時を売上日時とする
                                      sales_at: occurred_at,
                                      occurred_at: occurred_at,
                                      notification: notification)

    # 成果が上がったものは非表示にする
    Hiding.create!(media_user: media_user, target: campaign)

    # ポイント追加
    Point.add_point_by_achievement(media_user, point_type, point, achievement)
  end

  # TODO: offer 用が必要かも

  #
  # ダミー成果用
  #
  # * 売上も上がってしまうので、使いどころ注意！
  #
  def self.add_dummy_achievement(media_user, offer, occurred_at)
    campaign = offer.campaign
    payment = offer.payment
    payment_is_including_tax = offer.payment_is_including_tax
    point = offer.point
    notification = nil

    self.add_achievement(media_user, campaign, payment, payment_is_including_tax, point,
                         occurred_at, notification, PointType::MANUAL)
  end

  # TODO: ここら辺のネットワークに依存した処理をどこかに一元化できないか？

  # 成果通知にオファー情報が含まれていればオファー情報を取得する
  def offer_id
    if notification.nil?
      return nil
    end

    if notification.kind_of?(AdcropsAchievementNotice)
      return notification.sad
    elsif notification.kind_of?(GreeAchievementNotice)
      return notification.media_session
    else
      return nil
    end

  end

  # TODO: 本来はモデルに書くものではない
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
