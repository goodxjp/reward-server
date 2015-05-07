# -*- coding: utf-8 -*-
module Api
  module V1
    class PointHistoriesController < ApplicationController
      def index
        @media_user = MediaUser.find(params[:media_user_id])

        @point_histories = PointHistory.where(media_user: @media_user).order(created_at: :desc)
      end
    end
  end
end
