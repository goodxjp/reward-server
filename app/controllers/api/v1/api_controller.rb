# -*- coding: utf-8 -*-
require 'openssl'

class Api::V1::ApiController < ApplicationController

  #
  # 署名が正しいかチェック
  #
  # - チェックが成功したら @medium と @media_user が設定されている。
  #
  def check_signature
    #logger.debug("request_method   = #{request.request_method}")
    #logger.debug("path             = #{request.path}")
    #logger.debug("query_parameters = #{request.query_parameters}")

    query = request.query_parameters
    sig = query.delete("sig")

    mid = params[:mid]
    uid = params[:uid]

    @medium = Medium.find(mid)
    @media_user = MediaUser.find(uid)

    correct_sig = self.class.make_signature(@medium, @media_user, request.request_method, request.path, query)

    if sig != correct_sig
      # TODO: 要ロギング
      # TODO: 回数が多かったら要通知
      render status: :forbidden, text: "お手数ではございますが、最初からやり直してください。(エラー番号: 0101)"  # ユーザへの通知方法要検討
    end
  end

  #
  # 署名作成
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

    key = "#{medium.key}&#{media_user.terminal_id}"
    data = "#{method}\n#{path}\n#{sorted_query_string}"
    #logger.debug("key = #{key}")
    #logger.debug("data =vvvvv\n#{data}")

    correct_sig = OpenSSL::HMAC.hexdigest('sha1', key, data)
    #logger.info("correct_sig = #{correct_sig}")

    return correct_sig
  end
end
