# -*- coding: utf-8 -*-
require 'openssl'

class Api::V1::ApiController < ApplicationController
  # Web API では CSRF トークン不要
  skip_before_action :verify_authenticity_token

  before_action :api_initialize

  # 例外ハンドリング
  # http://morizyun.github.io/blog/custom-error-404-500-page/
  # http://ruby-rails.hatenadiary.com/entry/20141111/1415707101
#  if not Rails.env.development?  # API では開発環境でも、下記を返した方が良い気がする。
    rescue_from Exception, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
#  end

  #
  # 全ての API で共通に行う処理
  #
  def api_initialize
    @now = Time.zone.now

    # アクセス日時を記録
    # TODO: 将来的には NoSQL に記録
  end

  #
  # 署名が正しいかチェック
  #
  # - チェックが成功したら @medium と @media_user が設定されている。
  #
  def check_signature
    #logger.debug("request_method   = #{request.request_method}")
    #logger.debug("path             = #{request.path}")
    #logger.debug("query_parameters = #{request.query_parameters}")

    mid = params[:mid]
    uid = params[:uid]
    avc = params[:avc]

    @medium = Medium.find(mid)
    @media_user = MediaUser.find(uid)

    check_signature_with_model(@medium, @media_user)

    # 不正なアクセスを処理しないために署名チェック後に MediaUserUpdate を更新
    update_media_user_update(@media_user, avc)

    # TODO: 後でメソッド名を適切なものに

    # ユーザーの状態をチェック
    if @media_user.available == false
      respond_to do |format|
        format.json { render_error(9005) }
        format.html { render status: :forbidden, text: "お手数ですが、最初からやり直していただけますか？" }
      end
    end
  end

  #
  # 署名が正しいかチェック (ユーザーが特定されていない API 用)
  #
  # - チェックが成功したら @medium が設定されている。
  #
  def check_signature_without_uid
    #logger.debug("request_method   = #{request.request_method}")
    #logger.debug("path             = #{request.path}")
    #logger.debug("query_parameters = #{request.query_parameters}")

    mid = params[:mid]
    avc = params[:avc]

    @medium = Medium.find(mid)

    check_signature_with_model(@medium, nil)
  end

  #
  # 署名作成
  #
  # - media_user は nil 可
  #
  def self.make_signature(medium, media_user, method, path, query)
    sorted_query = query.sort  # => [["aaa", "1"], ["bbb", "2"], ["ccc", "1"], ["ddd", "16"]]
    sorted_query_array = []    # => ["aaa=1", "bbb=2", "ccc=1", "ddd=16"]
    sorted_query.each do |i|
      sorted_query_array << i.join('=')
    end
    sorted_query_string = sorted_query_array.join('&')
    #logger.debug("sorted_query = #{sorted_query}")
    #logger.debug("sorted_query_string = #{sorted_query_string}")

    if media_user.nil?
      key = "#{medium.key}&"
    else
      #key = "#{medium.key}&#{media_user.terminal_id}"
      key = "#{medium.key}&#{media_user.key}"
    end
    data = "#{method}\n#{path}\n#{sorted_query_string}"
    #logger.debug("key = #{key}")
    #logger.debug("data =vvvvv\n#{data}")

    correct_sig = OpenSSL::HMAC.hexdigest('sha1', key, data)
    #logger.info("correct_sig = #{correct_sig}")

    return correct_sig
  end

  #
  # API エラーコード関連
  #
  # - コード表はどこかに分割した方がよさげ。
  #
  def render_error(code)
    error_code = ERROR_CODE[code]

    if error_code.nil?
      logger_fatal "Cannot find error code(#{code})."
      render status: 400, json: { code: code, message: ERROR_CODE[0][:message] }
    else
      render status: 400, json: { code: code, message: error_code[:message] }
    end
  end

  def render_500(e = nil)
    logger_fatal "Rendering 500 with exception: #{e.message}" if e
    code = 9001
    render status: 500, json: { code: code, message: ERROR_CODE[code][:message] }
  end

  def render_404(e = nil)
    logger_fatal "Rendering 404 with exception: #{e.message}" if e
    code = 9002
    render status: 404, json: { code: code, message: ERROR_CODE[code][:message] }
  end

  # message はユーザー向けのメッセージなので、ユーザーに不要な情報を記入しないこと！
  # メッセージはアプリケーション埋め込みのものが優先。
  ERROR_CODE = {
    #
    # メディアユーザー系
    #
    # ユーザーキーが作成できなかった
    1001 => { message: "もう一度、起動し直すか、再インストールをお願いします。" },
    # ユーザー関連のデータ保存に失敗 (滅多に起きないが、ユーザーキーの競合がありうる)
    1002 => { message: "もう一度、起動し直すか、再インストールをお願いします。" },
    # すでに使用している端末がある TODO: あとで削除
    1999 => { message: "お使いの端末にはインストールできません。" },

    #
    # 案件系
    #

    #
    # 購入系
    #
    # 全体的なポイント交換制限全般
    2001 => { message: "しばらくたってから、再度お試し下さい。" },
    # 個人的なポイント交換制限全般
    2002 => { message: "しばらくたってから、再度お試し下さい。" },
    # 商品 ID 不正 (商品を無効にすると発生することがある)
    2003 => { message: "お手数ですが、最初からやり直して下さい。" },
    # ポイント数不正 (商品のポイント数を変更にすると発生することがある)
    2004 => { message: "お手数ですが、最初からやり直して下さい。" },
    # 1 日 1 回までしか交換できない
    2005 => { message: "交換は 1 日に 1 回までになります。明日以降にもう一度お試し下さい。" },
    # ポイント不足
    2006 => { message: "ポイントが足りません。" },
    # 在庫切れ
    2007 => { message: "該当の商品の在庫がございません。今しばらくお待ちください。" },
    # ギフト券購入済み (競合エラー)
    2008 => { message: "お手数ですが、最初からやり直して下さい。" },

    #
    # 共通
    #
    # 想定外の例外
    9001 => { message: "Sorry for the inconvenience. Please wait for a while." },
    # ActiveRecord::RecordNotFound, ActionController::RoutingError
    9002 => { message: "Sorry for the inconvenience. Please wait for a while." },
    # データベースのデータ不整合 (FATAL ログできちんと原因を検出できる用にしておくこと)
    9003 => { message: "現在、復旧作業中です。今しばらくお待ちください。" },
    # 署名エラー
    9004 => { message: "お手数ですが、最初からやり直してください。" },
    # ユーザー停止中
    9005 => { message: "お手数ですが、最初からやり直してください。" },

    # 強制終了
    9999 => { message: "" },

    # このエラーコードのメッセージはアプリに埋め込まないこと。
    0 => { message: "" }
  }

  private
    def update_media_user_update(media_user, app_version_code)
      media_user_update = MediaUserUpdate.find_by_media_user_id(media_user.id)

      # TODO: 移行期のためここでも作る
      if media_user_update.nil?
        media_user_update = MediaUserUpdate.new(media_user: media_user)
      end

      media_user_update.last_access_at = @now
      media_user_update.app_version_code = app_version_code

      media_user_update.save!
    end

    def check_signature_with_model(medium, media_user)
      query = request.query_parameters
      sig = query.delete("sig")

      correct_sig = self.class.make_signature(medium, media_user, request.request_method, request.path, query)

      if sig != correct_sig
        logger_fatal("Signature error. (#{media_user.to_s}")  # media_user = nil の場合あり

        # 案件実行時には JSON ではなく HTML でエラー表示する必要がある。
        # TODO: 案件実行の時に日本語前提になっちゃってる。まぁ、不正な処理なのでいいかな。
        respond_to do |format|
          format.json { render_error(9004) }
          format.html { render status: :forbidden, text: "お手数ですが、最初からやり直していただけますか？" }
        end
        # ↑は before_～ で使うのが前提の処理になっちゃってるけど、まぁ、いっかな。
        # http://techracho.bpsinc.jp/baba/2013_08_06/12650
      end
    end

end
