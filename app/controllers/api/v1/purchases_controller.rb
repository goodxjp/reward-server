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
        # 各種チェック
        #
        # - ここではユーザーに依存しない全体なチェックのみ
        #

        # 短時間での交換制限
        # - とりあえず、過去 1 時間に 10 万ポイント以上交換されたら危険なので、止めてしまう。
        # - まだ、ユーザー数がほとんどいないはずなので、あり得ないはず。
        from = @now - 1.hour
        sum_point_num = Purchase.where("? <= occurred_at", from).sum(:point)
        if  sum_point_num >= 100000  # TODO: 設定化
          logger_fatal "Over exchange. (100,000 points in 1 hour)"
          render_error(2001) and return
        end

        # ポイントを持ってるかどうかは (ポイント消費の時にエラーがおこるのそれで OK)
        # アプリの方でもはじくので、そんなに頻発しないはず。

        # 商品があるかチェック
        # - 商品を無効にすることで発生する。
        item = Item.find_by(id: item_params[:id], available: true)
        if item.nil?
          # 普通あり得ないので、頻繁に起こってないかログでチェック
          logger_fatal "Item #{item_params[:id]} is not found."
          render_error(2003) and return
        end

        # ポイントが正しいかチェック
        # - 商品のポイント数を変更することで発生する。
        # - このチェックが通った後で、商品のポイント数が変更になったとしても、
        #   パラメータで来たとおりのポイント数で購入される
        if not (item.point * item_params[:number] == item_params[:point])
          # 普通あり得ないので、頻繁に起こってないかログでチェック
          logger_fatal "Point(#{item_params[:point]}) is incorrect. (item.point = #{item.point}, number = #{item_params[:number]})"
          render_error(2004) and return
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
          rescue Purchase::GiftPurchasedError => e
            logger.error e.message
            logger.error "Transaction rollback."
            sleep(count * 1)
            next
          rescue Purchase::OverPurchaseError => e
            logger.error e.message
            logger.error "Transaction rollback."
            render_error(2005) and return  # このエラーコードは 1 日 1 回制限前提
          rescue Purchase::LackOfPointError => e
            logger.error e.message
            logger.error "Transaction rollback."
            render_error(2006) and return
          rescue Purchase::LackOfStockError => e
            logger_fatal e.message
            logger.error "Transaction rollback."
            render_error(2007) and return
          rescue => e
            # リトライせずに即座にエラー
            logger_fatal e.message
            logger.error "Transaction rollback."

            # 上位でレスポンスを返す
            raise e
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

