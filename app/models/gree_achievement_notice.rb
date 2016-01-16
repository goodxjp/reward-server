# -*- coding: utf-8 -*-
#
# GREE 成果通知
#
class GreeAchievementNotice < ActiveRecord::Base
  belongs_to :campaign_source

  def type_name
    "GREE"
  end
end
