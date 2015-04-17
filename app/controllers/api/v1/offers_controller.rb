# -*- coding: utf-8 -*-
module Api
  module V1
    class OffersController < ApplicationController

      def index
        mid = params[:mid]
        uid = params[:uid]

        # TODO: 将来的にはメディア、ユーザーの特定を共通化

        # メディアの特定
        medium = Medium.find(mid)  # 署名チェックをしていれば mid は必ず存在するはず

        # ユーザーの特定
        #medir_user = MediaUser.find(uid)

        @offers = Offer.where(:available => true, :medium => medium)
      end

      # 厳密にはブラウザから呼ばれるので API ではない
      def execute
        offer = Offer.find(params[:id])

        # TODO: 署名のチェック

        if offer.available == false
          render :text => "案件が終了したか、獲得条件、ポイント数などが変更になっている可能性があります。お手数ではございますが、最初からやり直してください。"
          return
        end

        # TODO: クリック履歴の記録
        logger.debug("remote_ip = #{request.remote_ip}")

        redirect_to offer.url
      end
    end
  end
end
