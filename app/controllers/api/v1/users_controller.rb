# -*- coding: utf-8 -*-
module Api
  module V1
    class UsersController < ApiController
      before_action :check_signature, except: [ :create ]
      before_action :check_signature_without_uid, only: [ :create ]

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
        # TODO: メディア情報、メディア種別保持
        # TODO: iOS など他のメディア種別を考慮

        # TODO: 端末 ID の不正に対処 (ログから情報を検索できるように)

        # すでに端末が登録されていないかチェック
        # TODO: 更新できる情報は更新
        @media_user = MediaUser.find_by_terminal_id(params[:user][:terminal_id])
        if not @media_user.nil?
          logger.debug "Registered terminal_id = #{@media_user.terminal_id}."
          render :show and return
        end

        @media_user = MediaUser.new(user_params)

        # 端末情報は JSON で保存
        terminal_info = params[:user][:terminal_info]
        @media_user.terminal_info = terminal_info.to_json

        if @media_user.save
          render :show
        else
          # TODO: エラーコードを全体的に要検討
          render :nothing => true, :status => 400
        end
      end

      private
        def user_params
          params.require(:user).permit(:terminal_id, :android_registration_id)
        end
    end
  end
end
