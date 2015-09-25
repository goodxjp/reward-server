# -*- coding: utf-8 -*-
module Api
  module V1
    class OffersController < ApiController
      before_action :check_signature

      helper_method :make_execute_url

      #
      # 案件一覧
      #
      def index
        offers = Offer.where(available: true, medium: @medium).order(id: :desc)

        @offers = []
        offers.each do |offer|
          # 非表示のものをチェック
          hidings = Hiding.where(media_user: @media_user, target: offer.campaign)
          next if (hidings.size > 0)

          @offers << offer
        end
      end

      #
      # 案件実行
      #
      # - 厳密にはブラウザから呼ばれるので API ではない。
      # - この URL は多言語化されていない。
      #
      def execute
        offer = Offer.find(params[:id])

        if offer.available == false
          # TODO: クリックログに記録したい
          render :text => "案件が終了したか、獲得条件、ポイント数などが変更になっている可能性があります。お手数ではございますが、最初からやり直してください。"
          return
        end

        # URL 書き換え
        offer.url.gsub!('$USER_ID$', @media_user.id.to_s)
        offer.url.gsub!('$OFFER_ID$', offer.id.to_s)
        if not offer.campaign.campaign_source.nil?
          if offer.campaign.campaign_source.network_system == NetworkSystem::GREE
            digest = NetworkSystemGree.make_gree_digest_for_redirect_url(offer.campaign, @media_user)
            if digest == nil
              logger_fatal("Cannot find GreeConfig (campaing_source_id = #{offer.campaign.campaign_source_id}")
              # TODO: クリックログに記録したい
              render :text => "案件が終了したか、獲得条件、ポイント数などが変更になっている可能性があります。お手数ではございますが、最初からやり直してください。"  # 嘘ですけど
              return
            end
            offer.url.gsub!('$GREE_DIGEST$', digest)
          end
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
