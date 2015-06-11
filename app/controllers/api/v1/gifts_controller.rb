# -*- coding: utf-8 -*-
module Api
  module V1
    class GiftsController < ApiController
      before_action :check_signature

      def index
        uid = params[:uid]
        media_user = MediaUser.find(uid)

        # 他人のは絶対に返さないこと！
        @gifts = Gift.joins(:purchase).where(purchases: { media_user_id: media_user }).order('purchases.created_at DESC', id: :desc)
      end
    end
  end
end