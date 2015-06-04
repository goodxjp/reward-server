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

        # 購入処理
        begin
          # モデルのトランザクションとの違いは？
          ActiveRecord::Base.transaction do
            purchase(media_user, item, item_params[:number], item_params[:point])
          end
        rescue => e
          logger.error "Transaction rollback."

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
        tmp_point = point  # 消費すべきポイント
        # TODO: 有効無効フラグは付けておいた方が効率いいかも
        media_user.points.each do |p|  # TODO: 有効期限順で並べ替える必要あり、ID ぐらいでもいいかも
          if tmp_point <= p.remains
            p.remains = p.remains - tmp_point
            tmp_point = 0
          else
            p.remains = 0
            tmp_point = tmp_point - p.remains
          end

          p.save!

          break if tmp_point == 0
        end

        # 資産が足りないかチェック
        if not tmp_point == 0
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
        # TODO: 複数同時に走ると絶対にギフトが被るので、繰り返し行う必要がある

        # TODO: 同時に購入がされる場合のテスト
        # 在庫をチェック
        # 順序を一定にしておかないとデッドロックが発生する
        logger.error "-----> Gift.where start"  # TODO: ここでロックする？
        gifts = Gift.where(item: item, purchase: nil).order(id: :asc).limit(number)
        logger.error "-----> Gift.where end"
        # TODO: 同時アクセスが多くなるとロールバックのケースが多くなってしまう気がする。
        #       ランダム性を持たせたり工夫した方がよさげ。

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
          logger.error "------------------- user = #{media_user.id}, gift = #{gift.id}"

          # 交換ギフト券確保
          gift.lock!  # TODO: 複数ギフト購入が走った場合に実際にはどこでロックしているかチェック

          # ほんとに交換済みでないか念のためチェック (参照時にロックされる？)
          if not gift.purchase.nil?
            # TODO: 起こりうる？
            # A が先に 1 個とって 1 つ目をロックしている間に、B が同じ 1 個を取得しようとして待っている間に、A が購入すると起こるかな。
            message = "Gift(#{gift.if}) is purchased."
            logger.error message
            raise message
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
  end
end
