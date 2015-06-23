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
        # TODO: Android 特有の保存場所を変更

        # TODO: 端末 ID の不正に対処 (ログから情報を検索できるように)

        # すでに端末が登録されていないかチェック
        # TODO: 登録されているかどうかの端末チェックを厳密に (他人の端末で登録されてしまわないように)
        # 端末 ID はあまり信用しないこと。
        @media_user = MediaUser.find_by_terminal_id(params[:user][:terminal_id])
        if not @media_user.nil?
          logger.debug "Registered terminal_id = #{@media_user.terminal_id}."
        else
          # 登録済みでなければ、新規作成
          @media_user = MediaUser.new(user_params)
        end

        @media_user.medium = @medium

        # ユーザーキーを作成
        for count in 1..3 do
          key = MediaUser.make_user_key
          if MediaUser.find_by_key(key).nil?
            @media_user.key = key
            break
          else
            logger.warn "Registered key = #{key}."
          end
        end

        if @media_user.key.nil?
          # 滅多に起こらないはずだが、ロギング
          # TODO: エラーコードを全体的に要検討
          logger.error "Registered key."
          render :nothing => true, :status => 400 and return
        end

        # 端末情報は JSON で保存
        terminal_info = params[:user][:terminal_info]
        @media_user.terminal_info = terminal_info.to_json

        # TODO: key でユニーク制約をかけて、エラーのテスト
        if @media_user.save
          render :show
        else
          # 滅多に起こらないはずだが、ユーザーキーが被って失敗する可能性あり。
          # TODO: エラーコードを全体的に要検討
          logger.error "Cannot make MediaUser (#{@media_user.to_json})."
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
