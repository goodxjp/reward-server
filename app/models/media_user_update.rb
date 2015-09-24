# -*- coding: utf-8 -*-
class MediaUserUpdate < ActiveRecord::Base
  belongs_to :media_user

  #
  # Validator
  #
  # これって、モデルにかけるべきか？ID にかけるべきか？
  # http://railsguides.net/belongs-to-and-presence-validation-rule1/
  validates :media_user,
    presence: true
  #validates :media_user_id,
  #  presence: true
end
