# -*- coding: utf-8 -*-
module Api
  module V1
    class PointHistoriesController < ApiController
      before_action :check_signature

      def index
        # TODO: 古い API 用。あとで消す
        if not params[:media_user_id].nil?
          @media_user = MediaUser.find(params[:media_user_id])
          @point_histories = PointHistory.where(media_user: @media_user).order(created_at: :desc)
          render :index and return
        end

        # TODO: 発生日ベースに
        @point_histories = PointHistory.where(media_user: @media_user).order(created_at: :desc)
      end
    end
  end
end
