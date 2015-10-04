# -*- coding: utf-8 -*-
class Purchase < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :item

  validates :media_user,
    :presence => true
  validates :item,
    :presence => true
  validates :number,
    :presence => true
  validates :point,
    :presence => true

  #
  # ギフト券購入処理
  #
  # - 外でトランザクションかける前提だから、エラーは例外で返す必要あり。
  #
  def self.purchase(media_user, item, number, point_num, occurred_at)
    media_user.lock!  # ポイント関連の一覧の更新や、ユーザーの状態をチェックする前にユーザーでロックしておく

    #
    # 各種チェック (ユーザー別)
    #

    # 1 日 1 回しか交換できない
    from = Time.zone.local(occurred_at.year, occurred_at.month, occurred_at.day, 0, 0, 0)
    next_day = occurred_at.tomorrow
    to = Time.zone.local(next_day.year, next_day.month, next_day.day, 0, 0, 0)
    purchases = Purchase.where(media_user: media_user).where("? <= occurred_at AND occurred_at < ?", from, to)

    if purchases.size > 0
      message = "User have already purchased today (media_user.id = #{media_user.id})."
      logger.info message
      raise OverPurchaseError, message
    end

    #
    # ポイントの消費
    #

    # ポイント資産から消費
    consumed_point_num = point_num  # 消費すべきポイント
    media_user.points.where(available: true).where('? < expiration_at', occurred_at).order('expiration_at IS NULL', expiration_at: :asc, occurred_at: :asc).each do |p|
      # 今回、減らすポイント
      reduce_point_num = [consumed_point_num, p.remains].min

      # どっちかは 0 になる
      consumed_point_num = consumed_point_num - reduce_point_num
      p.remains = p.remains - reduce_point_num
      p.available = false if p.remains == 0

      p.save!

      break if consumed_point_num == 0
    end

    # 資産が足りないかチェック
    if not consumed_point_num == 0
      message = "Point is not enough (media_user.id = #{media_user.id})."
      logger.info message
      raise LackOfPointError, message
    end

    # 所有ポイントの消費 or 再計算
    media_user.point = media_user.point - point_num
    media_user.save!

    # TODO: 資産の再計算チェック

    # ポイント履歴の追加
    point_history = PointHistory.new()
    point_history.media_user   = media_user
    point_history.point_change = -point_num
    # TODO: ここも日本語前提
    if (number == 1)
      point_history.detail = "ポイント交換 (#{item.name}})"
    else
      point_history.detail = "ポイント交換 (#{item.name} × #{number})"
    end
    point_history.source       = @purchase
    point_history.save!

    #
    # 商品取得
    #

    # TODO: 同時に購入がされる場合のテスト
    # 在庫をチェック
    # 順序を一定にしておかないとデッドロックが発生する
    logger.debug "Gift.where start"  # TODO: ここでロックする？
    gifts = Gift.where(item: item, purchase: nil).order('expiration_at IS NULL', expiration_at: :asc).limit(number)
    logger.debug "Gift.where end"
    # TODO: 同時アクセスが多くなるとここで複数のユーザーが同じギフト券を確保してしまうので、
    #       ロールバックのケースが多くなってしまう気がする。
    #       ランダム性を持たせたり工夫した方がよさげ。
    #       ランダムに数個飛ばすでよいかも。在庫が十分にあればそれほど問題にならない。

    # 在庫切れチェック
    if gifts.size != number
      message = "Gift is not enough (item.id = #{item.id})."
      logger.error message
      raise LackOfStockError, message
    end

    # 購入作成
    purchase = Purchase.new(media_user: media_user, item: item, number: number, point: point_num, occurred_at: occurred_at)
    purchase.save!

    # ギフト券更新 (複数個に対応)
    # TODO: 事前にギフト券を取得しないで、
    # ここで注文個数に達するまで一個ずつとってきて、エラーが起きたら次のギフト券を取りにいった方がいいかも。
    gifts.each do |gift|
      logger.debug "Gift.lock! user = #{media_user.id}, gift = #{gift.id}"

      # 交換ギフト券確保
      gift.lock!  # TODO: 複数ギフト購入が走った場合に実際にはどこでロックしているかチェック

      # ほんとに交換済みでないか念のためチェック (参照時にロックされる？)
      if not gift.purchase.nil?
        # TODO: 起こりうる？
        # A が先に Gift A を確保して、上の gift.lock で Gift A をロックしている間に、
        # B が同じ Gift A を確保して、上の gift.lock で待ってて、
        # その後 A が購入完了して Gift A のロックを解除すると起こるかな。
        message = "Gift(#{gift.if}) is purchased."
        logger.error message
        raise GiftPurchasedError, message
      end

      gift.purchase = purchase
      gift.save!
    end

    return purchase
  end

  # 過剰購入エラー
  class OverPurchaseError < StandardError
  end

  # ポイント不足エラー
  class LackOfPointError < StandardError
  end

  # 在庫切れエラー
  class LackOfStockError < StandardError
  end

  # ギフト券購入済み (競合エラー)
  class GiftPurchasedError < StandardError
  end
end
