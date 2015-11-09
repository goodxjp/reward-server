# -*- coding: utf-8 -*-
#
# GREE キャンペーン
#
class GreeCampaign < ActiveRecord::Base
  belongs_to :campaign_source

  #
  # Validator
  #
  validates :campaign_source,
    presence: true
end
