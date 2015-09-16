# -*- coding: utf-8 -*-
require 'openssl'

class Api::V1::ApiController < ApplicationController
  # Web API では CSRF トークン不要
  skip_before_action :verify_authenticity_token

  before_action :api_initialize

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

    # 署名チェックの前に MediaUserUpdate を更新
    update_media_user_update(@media_user, avc)

    check_signature_with_model(@medium, @media_user)
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

  private
    def update_media_user_update(media_user, app_version_code)
      media_user_update = MediaUserUpdate.find_by_media_user_id(media_user.id)

      # TODO: 移行期のためここでも作る
      if media_user_update.nil?
        media_user_update = MediaUserUpdate.new(media_user: media_user, last_access_at: @now, app_version_code: app_version_code)
        if not media_user_update.save
          logger_fatal "Cannot make MediaUserUpdate (#{@media_user.to_json})."
          render :nothing => true, :status => 400
        end
      else
        media_user_update.last_access_at = @now
        media_user_update.app_version_code = app_version_code
        if not media_user_update.save
          # TODO: エラーコードを全体的に要検討。ロギングできるのであれば例外投げちゃってもいいかも
          logger_fatal "Cannot update MediaUserUpdate (#{@media_user.to_json})."
          render :nothing => true, :status => 400
        end
      end
    end

    def check_signature_with_model(medium, media_user)
      query = request.query_parameters
      sig = query.delete("sig")

      correct_sig = self.class.make_signature(medium, media_user, request.request_method, request.path, query)

      if sig != correct_sig
        # TODO: 回数が多かったら要通知
        logger.error("Signature error.")
        # TODO: ユーザへの通知方法要検討
        render status: :forbidden, text: "お手数ではございますが、最初からやり直してください。(エラー番号: 0101)"
        # before_～ で使うのが前提の処理だけど、まぁ、いっかな。
        # http://techracho.bpsinc.jp/baba/2013_08_06/12650
      end
    end

end
