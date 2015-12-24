# -*- coding: utf-8 -*-
require 'openssl'

class Notice::NoticeController < ApplicationController
  # Web API では CSRF トークン不要
  skip_before_action :verify_authenticity_token

  before_action :notice_initialize

  # 例外ハンドリング
  # http://morizyun.github.io/blog/custom-error-404-500-page/
  # http://ruby-rails.hatenadiary.com/entry/20141111/1415707101
  rescue_from Exception, with: :render_500
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  #
  # 全ての通知で共通に行う処理
  #
  def notice_initialize
    @now = Time.zone.now
  end

  #
  # 例外処理
  #
  def render_500(e = nil)
    LogUtil.fatal "Rendering 500 with exception: #{e.message}" if e
    LogUtil.fatal e.backtrace.join("\n")
    render status: 500, nothing: true
  end

  def render_404(e = nil)
    LogUtil.fatal "Rendering 404 with exception: #{e.message}" if e
    LogUtil.fatal e.backtrace.join("\n")
    render status: 404, nothing: true
  end
end
