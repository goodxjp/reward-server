# -*- coding: utf-8 -*-
module Api
  module V1
    class OffersController < ApiController
      before_action :check_signature

      helper_method :make_execute_url

      def index
        # TODO: ソート順検討
        offers = Offer.where(available: true, medium: @medium).order(id: :desc)

        @offers = []
        offers.each do |offer|
          # TODO: 非表示のものをチェック
          #hiding = Hiding.where(media_user: @media_user, target: offer.campaign)
          next if (offer.point > 1000)

          @offers << offer
        end
      end

      # 厳密にはブラウザから呼ばれるので API ではない
      def execute
        offer = Offer.find(params[:id])

        if offer.available == false
          render :text => "案件が終了したか、獲得条件、ポイント数などが変更になっている可能性があります。お手数ではございますが、最初からやり直してください。"
          return
        end

        #
        # クリック履歴の記録
        #

        # リクエスト情報取得
        # TODO: 項目精査
        request_info = {}
        request_info["ip"] = request.ip
        request_info["remote_ip"] = request.remote_ip
        request_info["user_agent"] = request.user_agent

        click_history = ClickHistory.new()
        click_history.media_user   = @media_user
        click_history.offer        = offer
        click_history.request_info = request_info.to_json
        click_history.ip_address   = request.remote_ip

        if not click_history.save
          # TODO: 要通知
          render :text => "案件が終了したか、獲得条件、ポイント数などが変更になっている可能性があります。お手数ではございますが、最初からやり直してください。"  # 嘘ですけど
          return
        end

        # URL 書き換え
        offer.url.gsub!('$USER_ID$', @media_user.id.to_s)
        offer.url.gsub!('$OFFER_ID$', offer.id.to_s)

        redirect_to offer.url
      end

      # ブラウザで叩かれる案件実行 URL を生成
      def make_execute_url(offer, mid, uid)
        medium = Medium.find(mid)
        media_user = MediaUser.find(uid)
        sig = Api::V1::ApiController.make_signature(medium, media_user, "GET", execute_api_v1_offer_path(offer), { mid: mid, uid: uid })

        return execute_api_v1_offer_url(offer, mid: mid, uid: uid, sig: sig)
      end
    end
  end
end
