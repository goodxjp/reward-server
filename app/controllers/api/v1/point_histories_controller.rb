# -*- coding: utf-8 -*-
module Api
  module V1
    class PointHistoriesController < ApiController
      before_action :check_signature

      def index
        @point_histories = PointHistory.where(media_user: @media_user).order(occurred_at: :desc)
      end
    end
  end
end
