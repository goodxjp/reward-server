# -*- coding: utf-8 -*-
module Api
  module V1
    class GiftsController < ApiController
      before_action :check_signature

      def index
        # 他人のは絶対に返さないこと！
        @gifts = Gift.joins(:purchase).where(purchases: { media_user_id: @media_user.id }).order('purchases.occurred_at DESC', id: :desc)
        #puts @gifts.to_json
      end
    end
  end
end
