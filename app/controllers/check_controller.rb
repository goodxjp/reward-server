# -*- coding: utf-8 -*-
#
# ヘルスチェック
#
class CheckController < ApplicationController
  # 集中してでアクセスされてもある程度大丈夫なように。
  # 認証なしでアクセスされる可能性があるので注意！
  def index
    ActiveRecord::Base.connection.execute("SELECT 1")

    render status: :ok, text: "I hate programming so much."
  end
end
