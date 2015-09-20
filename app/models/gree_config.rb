# -*- coding: utf-8 -*-
#
# GREE 登録時に割り振られるパラメータ
#
class GreeConfig < ActiveRecord::Base
  belongs_to :campaign_source

  #
  # Validator
  #
  validates :campaign_source,
    presence: true
  validates :media_identifier,
    presence: true
  validates :site_key,
    presence: true
end
