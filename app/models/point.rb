# -*- coding: utf-8 -*-
class Point < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :media_user

  # TODO: ルールを決める
  # 基本は成果通知がソース。
  # 手動の時はキャンペーンがソース？nil がいい？となるとポリモフィリックの意味なくね？
  belongs_to :source, :polymorphic => true

  # belongs_to_active_hash :point_type  # 古い？
  belongs_to :point_type

  # トランザクションは外部でかける
  # メディアユーザーに対して、スレッドセーフではない
  def self.add_point_by_achievement(media_user, type, point, achievement)
    p = Point.new
    p.media_user    = media_user
    p.point_type    = type
    p.source        = achievement
    p.point         = point
    p.remains       = point
    p.expiration_at = achievement.occurred_at + 1.years  # TODO: 有効期限を決める

    point_history = PointHistory.new()
    point_history.media_user   = media_user
    point_history.point_change = point
    point_history.detail       = achievement.campaign.name
    point_history.source       = achievement

    media_user.point       = media_user.point       + point
    media_user.total_point = media_user.total_point + point

    p.save!
    point_history.save!
    media_user.save!
  end

  # トランザクションは外部でかける
  # メディアユーザーに対して、スレッドセーフではない
  def self.add_point(media_user, type, point, detail)
    p = Point.new
    p.media_user    = media_user
    p.point_type    = type
    p.source        = nil
    p.point         = point
    p.remains       = point
    p.expiration_at = nil

    point_history = PointHistory.new()
    point_history.media_user   = media_user
    point_history.point_change = point
    point_history.detail       = detail
    #point_history.source       = p  # 以前はポイント資産が発生源
    point_history.source       = p

    media_user.point       = media_user.point       + point
    media_user.total_point = media_user.total_point + point

    p.save!
    point_history.save!
    media_user.save!
  end
end
