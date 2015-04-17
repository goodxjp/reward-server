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
    end
  end
end
