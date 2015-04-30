# -*- coding: utf-8 -*-
class MediaUser < ActiveRecord::Base
  has_many :points

  validates :terminal_id,
    :presence => true,
    :uniqueness => true

  # キャンペーンに対応した成果数
  def count_points_by_campaign(campaign)
    return Point.where(media_user: self).where(source_type: "Campaign", source: campaign).size
  end

  def version
    begin
      json = JSON.parse(terminal_info)
    #rescue JSON::ParserError => e
    rescue Exception => e
      logger.debug(e)
      return nil
    end
    return json["VERSION.RELEASE"]
  end

  def brand
    begin
      json = JSON.parse(terminal_info)
    #rescue JSON::ParserError => e
    rescue Exception => e
      logger.debug(e)
      return nil
    end
    return json["BRAND"]
  end

  def model
    begin
      json = JSON.parse(terminal_info)
    #rescue JSON::ParserError => e
    rescue Exception => e
      logger.debug(e)
      return nil
    end
    return json["MODEL"]
  end
end
