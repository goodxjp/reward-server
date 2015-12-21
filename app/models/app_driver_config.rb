# -*- coding: utf-8 -*-
#
# AppDriver 登録時に割り振られるパラメータ
#
class AppDriverConfig < ActiveRecord::Base
  belongs_to :campaign_source

  #
  # Validator
  #
  validates :campaign_source,
    presence: true
  validates :site_identifier,
    presence: true
  validates :site_key,
    presence: true
  validates :media_identifier,
    presence: true
end
