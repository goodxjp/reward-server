# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Heroku でログレベルが出力できないので、ログ出力メソッドを作成。
  # ログのカスタマイズ方法がわからないのと、rails_12factor と競合しそうなので、
  # とりあえず、単純なメソッドで共通化。
  #
  # TODO: もっと、きれいなやり方ありそう。
  def logger_fatal(message)
    logger.fatal "[FATAL] #{message}"
  end
end
