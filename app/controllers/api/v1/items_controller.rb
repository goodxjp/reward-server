# -*- coding: utf-8 -*-
module Api
  module V1
    class ItemsController < ApiController
      before_action :check_signature

      def index
        @items = Item.where(:available => true)
      end
    end
  end
end
