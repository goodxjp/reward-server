# -*- coding: utf-8 -*-
#
# ポイント資産
#
class Point < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  belongs_to :media_user

  # 基本は成果がソース。
  # 手動の時はキャンペーンがソース？nil がいい？となるとポリモフィリックの意味なくね？
  belongs_to :source, :polymorphic => true

  # belongs_to_active_hash :point_type  # この書き方は古い？
  belongs_to :point_type

  #
  # Validation
  #
  validates :media_user,
    presence: true
  validates :point_type,
    presence: true
  validates :point,
    presence: true
  validates :remains,
    presence: true
  validates :occurred_at,
    presence: true
  validates :available,
    presence: true

  #
  # 成果によるポイント追加
  #
  # - トランザクションは外部でかけること！
  # - メディアユーザーに対して、スレッドセーフではないので注意！
  #
  def self.add_point_by_achievement(media_user, type, point, achievement)
    p = Point.new
    p.media_user    = media_user
    p.point_type    = type
    p.source        = achievement
    p.point         = point
    p.remains       = point
    p.occurred_at   = achievement.occurred_at
    p.expiration_at = achievement.occurred_at + 1.years  # TODO: 有効期限を決める
    p.available     = true

    point_history = PointHistory.new()
    point_history.media_user   = media_user
    point_history.point_change = point
    point_history.detail       = achievement.campaign.name
    point_history.source       = achievement
    # TODO: 要検討
    # point_history.source       = achievement  # 追加の時はポイント資産の方がいいかな。
    # 手動のとき困るのと、あくまで補助的情報なので、遠くなっても OK

    # メディアユーザーでロックをかけておく必要がある。
    media_user.point       = media_user.point       + point
    media_user.total_point = media_user.total_point + point

    p.save!
    point_history.save!
    media_user.save!
  end

  # - トランザクションは外部でかけること！
  # - メディアユーザーに対して、スレッドセーフではないので注意！
  # 主にテストで使ってる？できれば廃止したい。
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
