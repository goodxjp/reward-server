# -*- coding: utf-8 -*-
module Api
  module V1
    class OffersController < ApplicationController
      helper_method :make_execute_url

      def index
        mid = params[:mid]
        uid = params[:uid]

        # TODO: 将来的にはメディア、ユーザーの特定を共通化

        # メディアの特定
        medium = Medium.find(mid)  # 署名チェックをしていれば mid は必ず存在するはず

        # ユーザーの特定
        #medir_user = MediaUser.find(uid)

        @offers = Offer.where(:available => true, :medium => medium)
        @mid = mid
        @uid = uid
      end

      # 厳密にはブラウザから呼ばれるので API ではない
      def execute
        mid = params[:mid]
        uid = params[:uid]

        offer = Offer.find(params[:id])

        # TODO: 署名のチェック

        if offer.available == false
          render :text => "案件が終了したか、獲得条件、ポイント数などが変更になっている可能性があります。お手数ではございますが、最初からやり直してください。"
          return
        end

        # クリック履歴の記録
        logger.debug("mid = #{params[:mid]}")
        logger.debug("uid = #{params[:uid]}")
        medium = Medium.find(mid)
        media_user = MediaUser.find(uid)

        # リクエスト情報取得
        # TODO: 項目精査
        request_info = {}
        request_info["ip"] = request.ip
        request_info["remote_ip"] = request.remote_ip
        request_info["user_agent"] = request.user_agent

        click_history = ClickHistory.new()
        click_history.media_user   = media_user
        click_history.offer        = offer
        click_history.request_info = request_info.to_json
        click_history.ip_address   = request.remote_ip

        if not click_history.save
          # TODO: 要通知
          render :text => "案件が終了したか、獲得条件、ポイント数などが変更になっている可能性があります。お手数ではございますが、最初からやり直してください。"  # 嘘
          return
        end

        redirect_to offer.url
      end

      # ブラウザで叩かれる案件実行 URL を生成
      def make_execute_url(offer, mid, uid)
        return execute_api_v1_offer_url(offer, :mid => mid, :uid => uid)
      end
    end
  end
end
