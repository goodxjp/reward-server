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

  def version
    begin
      json = JSON.parse(info)
    rescue JSON::ParserError => e
      return nil
    end
    return json["VERSION.RELEASE"]
  end

  def brand
    begin
      json = JSON.parse(info)
    rescue JSON::ParserError => e
      return nil
    end
    return json["BRAND"]
  end

  def model
    begin
      json = JSON.parse(info)
    rescue JSON::ParserError => e
      return nil
    end
    return json["MODEL"]
  end

end
