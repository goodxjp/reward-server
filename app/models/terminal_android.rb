# -*- coding: utf-8 -*-
#
# Android 端末
#
# - 実際には同じ端末でも、メディアが異なれば別の端末として保持。
#
class TerminalAndroid < ActiveRecord::Base
  belongs_to :media_user

  #
  # Validation
  #
  validates :media_user,
    presence: true
  validates :identifier,
    presence: true
  validates :available,
    presence: true
end
