# -*- coding: cp932 -*-
module LogUtil
  # Heroku でアラートを検出するために、ログメッセージにキーワードを挿入
  def self.fatal(message)
    Rails.logger.fatal "[FATAL] #{message}"
  end
end
