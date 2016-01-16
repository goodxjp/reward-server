# -*- coding: utf-8 -*-
#
# AppDriver 成果通知
#
class AppDriverAchievementNotice < ActiveRecord::Base
  belongs_to :campaign_source

  def type_name
    "AppDriver"
  end
end
