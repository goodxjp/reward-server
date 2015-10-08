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
        logger_fatal "User create! for Log test"  # TODO: しばらく、ログテスト用に出力

        # TODO: 端末 ID の不正に対処 (ログから情報を検索できるように)
        identifier = params[:user][:terminal_id][:id]

        #
        # 端末が登録チェック
        #
        # TODO: 登録されているかどうかの端末チェックを厳密に (他人の端末で登録されてしまわないように)
        # 端末 ID はあまり信用しないこと。
        if (@medium.media_type == MediaType::ANDROID)
          # 1 端末にインストールできるメディア数はたかがしれているので、全メディア分を取得してまわす

          # TODO: params[:user][:terminal_id] に入ってくる version と created_at を保存しておきたい。

          #terminals = TerminalAndroid.where(identifier: params[:user][:terminal_id], available: true)
          # ↑のときに params[:user][:terminal_id] に JSON が渡ってきたとき、↓みたいなログがでた。
          # F, [2015-10-08T20:47:22.056851 #8841] FATAL -- :
          # ActiveRecord::StatementInvalid (PG::UndefinedTable: ERROR:  missing FROM-clause entry for table "identifier"
          # LINE 1: ...s" WHERE "terminal_androids"."available" = $1 AND "identifie...
          #: SELECT "terminal_androids".* FROM "terminal_androids" WHERE "terminal_androids"."available" = $1 AND "identifier"."id" = '2273000afa576152' AND "identifier"."created_at" = '2015-10-08T20:47:21.508+09:00' AND "identifier"."version" = 1):
          #  app/controllers/api/v1/users_controller.rb:34:in `create'
          # すごく、怖いけど、パラメータと where の関係をあとで詳しく調査してみるか。
          # ひょっとしたら、パラメータで渡ってきたものを where にそのまま渡すのはすごく怪しいかも。

          terminals = TerminalAndroid.where(identifier: identifier, available: true)
          terminals.each do |terminal|
            if (terminal.media_user.medium == @medium)
              # インストール済みの端末あり

              # TODO: しばらく、一度インストールされた端末に再インストールできないようにしておく。
              logger_fatal "Registered terminal_id = #{params[:user][:terminal_id]}."
              render_error(1999) and return
            end
          end
        end

        @media_user = MediaUser.new(user_params)
        @media_user.medium = @medium

        # ユーザーキーを作成
        for count in 1..3 do
          key = MediaUser.make_user_key
          if MediaUser.find_by_key(key).nil?
          #if not MediaUser.find_by_key(key).nil?  # 1001 エラーのテスト用
            @media_user.key = key
            break
          else
            logger.warn "Registered key = #{key}."
          end
        end

        if @media_user.key.nil?
          # そんなに致命的ではないが、滅多に起こらないはずなので致命的でロギング。
          logger_fatal "Cannot make user key."
          render_error(1001) and return
        end

        #
        # メディアユーザー更新情報
        #
        media_user_update = MediaUserUpdate.new(media_user: @media_user, last_access_at: @now, app_version_code: params[:avc])

        # 端末情報は JSON で保存
        terminal_info = params[:user][:terminal_info]
        @media_user.terminal_info = terminal_info.to_json  # TODO: 後で削除

        #
        # 端末情報
        #
        if (@medium.media_type == MediaType::ANDROID)
          terminal = TerminalAndroid.new
          terminal.media_user = @media_user
          terminal.identifier = identifier
          #terminal.identifier = nil  # 1002 エラーのテスト用
          terminal.info = terminal_info.to_json
          terminal.android_version = terminal_info["VERSION.RELEASE"]
          terminal.android_registration_id = params[:user][:android_registration_id]
          terminal.available = true
        else
          logger_fatal "Media type is invalid (#{@medium.media_type_id})"
          render_error(9003) and return
        end

        begin
          # モデルのトランザクションとの違いは？
          ActiveRecord::Base.transaction do

            # TODO: key でユニーク制約をかけて、エラーのテスト
            @media_user.save!
            terminal.save!
            media_user_update.save!
          end
        rescue => e
          # 滅多に起こらないはずだが、ユーザーキーが被って失敗する可能性あり。
          logger_fatal e.message
          logger_fatal "Cannot make MediaUser (#{params})."
          render_error(1002) and return
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
