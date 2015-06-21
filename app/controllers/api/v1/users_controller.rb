# -*- coding: utf-8 -*-
module Api
  module V1
    class UsersController < ApiController
      before_action :check_signature

      #
      # ユーザー情報取得 API
      #
      def show
        # @media_user は check_signature で設定済み
        # ここまで到達したら @media_user は必ず設定されている。
      end

      #
      # ユーザー登録 API
      #
      def create
        # すでに端末が登録されていないかチェック
        @media_user = MediaUser.find_by_terminal_id(params[:terminal_id])
        if not @media_user.nil?
          logger.debug "Registered terminal_id = #{@media_user.terminal_id}."
          render "show" and return
        end

        @media_user = MediaUser.new(media_user_params)

        # TODO: (ユーザーが特定できていないときの) 署名のチェック

        terminal_info = params[:media_user][:terminal_info]
        @media_user.terminal_info = terminal_info.to_json

        if @media_user.save
          render "show"
        else
          # TODO: 致命的エラーのログのしくみ要検討
          render :nothing => true, :status => 400
        end
      end

      private
        def media_user_params
          params.require(:media_user).permit(:terminal_id, :terminal_info, :android_registration_id)
        end
    end
  end
end
