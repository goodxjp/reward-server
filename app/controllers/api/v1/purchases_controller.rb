# -*- coding: utf-8 -*-
module Api
  module V1
    class PurchasesController < ApiController
      skip_before_filter :verify_authenticity_token, :only => [ :create ]

      #
      # 商品購入 (ポイント交換) API
      #
      def create
        # ユーザーの特定
        media_user = MediaUser.find(params[:uid])

        # purchase コントローラだと purchase っていうパラメータで来ることが前提？
        # Parameters: {"item"=>{"id"=>1, "number"=>2, "point"=>1000}, "purchase"=>{}} と表示される

        #
        # いろいろチェック
        #

        # 交換上限

        # 1 日 1 回

        # そもそもポイント持ってるかは (ポイント消費の時にエラーがおこるからそれでよさげ)

        # 商品があるかチェック (無効にされている場合もある)
        item = Item.find_by(id: item_params[:id], available: true)
        if item.nil?
          # 普通あり得ないので、頻繁に起こってないかログでチェック
          logger.error "Item #{item_params[:id]} is not found."

          # TODO: エラーコードを全体的に要検討
          render :nothing => true, :status => 400
          return
        end

        # ポイントが正しいかチェック
        # この後、商品のポイントが変更になったとしても、取得商品数と消費ポイント数はパラメータで来たとおりになる
        if not (item.point * item_params[:number] == item_params[:point])
          # 普通あり得ないので、頻繁に起こってないかログでチェック
          logger.error "Point(#{item_params[:point]}) is incorrect. (item.point = #{item.point}, number = #{item_params[:number]})"

          # TODO: エラーコードを全体的に要検討
          render :nothing => true, :status => 400
          return
        end

        # 購入処理
        retry_count = 3
        for count in 1..retry_count do
          begin
            # モデルのトランザクションとの違いは？
            ActiveRecord::Base.transaction do
              purchase(media_user, item, item_params[:number], item_params[:point])
            end
            break
          rescue GiftPurchasedError => e
            logger.error e.message
            logger.error "Transaction rollback."
            sleep(count * 1)
            next
          rescue => e
            # リトライせずに即座にエラー
            logger.error e.message
            logger.error "Transaction rollback."

            # TODO: エラーコードとレスポンスを全体的に要検討
            render :nothing => true, :status => 400
            return
          end
        end

        # リトライ回数を超えたとき
        if count == retry_count
          logger.error "Retry fail."
            # TODO: エラーコードとレスポンスを全体的に要検討
          render :nothing => true, :status => 400
        end
      end

      #
      # 購入処理
      #
      def purchase(media_user, item, number, point)
        #
        # ポイントの消費
        #
        media_user.lock!  # ポイント関連の一覧の更新する前にユーザーでロックしておく

        # ポイント資産から消費
        consumed_point = point  # 消費すべきポイント
        # TODO: 有効なポイントだけ取得したほうがよい、有効無効フラグは付けておいた方が効率いいかも
        media_user.points.order('expiration_at IS NULL', expiration_at: :asc).each do |p|
          if consumed_point <= p.remains
            p.remains = p.remains - consumed_point
            consumed_point = 0
          else
            p.remains = 0
            consumed_point = consumed_point - p.remains
          end

          p.save!

          break if consumed_point == 0
        end

        # 資産が足りないかチェック
        if not consumed_point == 0
          message = "Point is not enough (media_user.id = #{media_user.id})."
          logger.error message
          raise message
        end

        # 所有ポイントの消費 or 再計算
        media_user.point = media_user.point - point
        media_user.save!

        # ポイント履歴の追加
        point_history = PointHistory.new()
        point_history.media_user   = media_user
        point_history.point_change = -point
        point_history.detail       = "ポイント交換 (#{item.name} * #{number})"
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
          raise message
        end

        # 購入作成
        @purchase = Purchase.new(media_user: media_user, item: item, number: number, point: point)
        @purchase.save!

        # 複数個対応
        gifts.each do |gift|
          logger.debug "Gift.lock! user = #{media_user.id}, gift = #{gift.id}"

          # 交換ギフト券確保
          gift.lock!  # TODO: 複数ギフト購入が走った場合に実際にはどこでロックしているかチェック

          # ほんとに交換済みでないか念のためチェック (参照時にロックされる？)
          if not gift.purchase.nil?
            # TODO: 起こりうる？
            # A が先に 1 個とって 1 つ目をロックしている間に、
            # B が同じ 1 個を取得しようとして待っていて、その後 A が購入すると起こるかな。
            message = "Gift(#{gift.if}) is purchased."
            logger.error message
            raise GiftPurchasedError, message
          end

          # 無理やり時間をかけてみる
          #sleep(10)

          gift.purchase = @purchase
          gift.save!
        end
      end

      private
        def item_params
          params.require(:item).permit(:id, :number, :point)
        end
    end

    # ギフトが購入済みだったときのエラー (ギフト券かぶり)
    class GiftPurchasedError < StandardError
    end
  end
end

