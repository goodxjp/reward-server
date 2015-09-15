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
      # - 更新にはこの API は使用しない
      #
      def create
        logger_fatal "User create!"  # TODO: しばらく、ログテスト用に出力

        # TODO: 端末 ID の不正に対処 (ログから情報を検索できるように)

        #
        # 端末が登録チェック
        #
        # TODO: 登録されているかどうかの端末チェックを厳密に (他人の端末で登録されてしまわないように)
        # 端末 ID はあまり信用しないこと。
        # TODO: これだと別メディアで登録されちゃう。
        if (@medium.media_type == MediaType::ANDROID)
          # 1 端末にインストールできるメディア数はたかがしれているので、全メディア分を取得してまわす
          terminals = TerminalAndroid.where(identifier: params[:user][:terminal_id])
          terminals.each do |terminal|
            if (terminal.media_user.medium == @medium)
              # インストール済みの端末あり

              # TODO: エラーコードを全体的に要検討
              logger_fatal "Registered terminal_id = #{params[:user][:terminal_id]}."
              render :nothing => true, :status => 400 and return
            end
          end
        end

        @media_user = MediaUser.new(user_params)
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
        @media_user.terminal_info = terminal_info.to_json  # TODO: 後で削除

        #
        # 端末情報
        #
        if (@medium.media_type == MediaType::ANDROID)
          @terminal = TerminalAndroid.new
          @terminal.media_user = @media_user
          @terminal.identifier = params[:user][:terminal_id]
          @terminal.info = terminal_info.to_json
          @terminal.android_version = terminal_info["VERSION.RELEASE"]
          @terminal.android_registration_id = params[:user][:android_registration_id]
          @terminal.available = true
        else
          logger_fatal "Media type is invalid (#{@medium.media_type_id})"
          render :nothing => true, :status => 400 and return
        end

        begin
          # モデルのトランザクションとの違いは？
          ActiveRecord::Base.transaction do

            # TODO: key でユニーク制約をかけて、エラーのテスト
            @media_user.save!
            @terminal.save!
          end
        rescue => e
          # 滅多に起こらないはずだが、ユーザーキーが被って失敗する可能性あり。
          # TODO: エラーコードを全体的に要検討
          logger.error "Cannot make MediaUser (#{@media_user.to_json})."
          render :nothing => true, :status => 400 and return
        end

        render :show
      end

      private
        def user_params
          params.require(:user).permit(:terminal_id, :android_registration_id)
        end
    end
  end
end
