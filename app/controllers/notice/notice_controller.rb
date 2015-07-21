# -*- coding: utf-8 -*-
require 'openssl'

class Notice::NoticeController < ApplicationController
  # Web API では CSRF トークン不要
  skip_before_action :verify_authenticity_token

  before_action :notice_initialize

  #
  # 全ての API で共通に行う処理
  #
  def notice_initialize
    @now = Time.zone.now
  end
end
