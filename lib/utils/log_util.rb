# -*- coding: cp932 -*-
module LogUtil
  # Heroku �ŃA���[�g�����o���邽�߂ɁA���O���b�Z�[�W�ɃL�[���[�h��}��
  def self.fatal(message)
    Rails.logger.fatal "[FATAL] #{message}"
  end
end
