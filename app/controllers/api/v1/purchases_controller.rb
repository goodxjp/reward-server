# -*- coding: utf-8 -*-
module Api
  module V1
    class PurchasesController < ApiController
      before_action :check_signature

      #
      # 商品購入 (ポイント交換) API
      #
      def create
        # purchase コントローラだと purchase っていうパラメータで来ることが前提？
        # Parameters: {"item"=>{"id"=>1, "number"=>2, "point"=>1000}, "purchase"=>{}} と表示される
        # config.wrap_parameters あたりの話。

        #
        # いろいろチェック (ここではユーザーに依存しない全体なチェックのみ)
        #

        # 交換上限

        # 1 日 1 回 → 購入時にチェック

        # そもそもポイント持ってるかどうかは (ポイント消費の時にエラーがおこるからそれで OK)
        # アプリの方でもはじくので、そんなに頻発しないはず。

        # 商品があるかチェック (無効にされている場合もある)
        item = Item.find_by(id: item_params[:id], available: true)
        if item.nil?
          # 普通あり得ないので、頻繁に起こってないかログでチェック
          logger.error "Item #{item_params[:id]} is not found."

          # TODO: エラーコードを全体的に要検討
          render :nothing => true, :status => 400 and return
        end

        # ポイントが正しいかチェック
        # この処理後、商品のポイントが変更になったとしても、
        # 取得商品数と消費ポイント数はパラメータで来たとおりの値で購入される
        if not (item.point * item_params[:number] == item_params[:point])
          # 普通あり得ないので、頻繁に起こってないかログでチェック
          logger.error "Point(#{item_params[:point]}) is incorrect. (item.point = #{item.point}, number = #{item_params[:number]})"

          # TODO: エラーコードを全体的に要検討
          render :nothing => true, :status => 400 and return
        end

        # 購入処理
        retry_count = 3
        for count in 1..retry_count do
          begin
            # モデルのトランザクションとの違いは？
            ActiveRecord::Base.transaction do
              @purchase = Purchase.purchase(@media_user, item, item_params[:number], item_params[:point], @now)
            end
            break
          rescue GiftPurchasedError => e
            logger.error e.message
            logger.error "Transaction rollback."
            sleep(count * 1)
            next
          rescue => e
            # リトライせずに即座にエラー
            logger_fatal e.message
            logger.error "Transaction rollback."

            # 上位でレスポンスを返す
            raise e
#            render :nothing => true, :status => 400 and return
          end
        end

        # リトライ回数を超えたとき
        if count == retry_count
          logger.error "Retry fail."
          # TODO: エラーコードとレスポンスを全体的に要検討
          render :nothing => true, :status => 400 and return
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

