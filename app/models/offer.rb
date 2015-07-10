# -*- coding: utf-8 -*-
class Offer < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :medium

  belongs_to :campaign_category

  def self.create_from_campaign(medium, campaign)
    offer = Offer.new

    offer.campaign           = campaign
    offer.medium             = medium
    offer.campaign_category  = campaign.campaign_category
    offer.name               = campaign.name
    offer.detail             = campaign.detail
    offer.icon_url           = campaign.icon_url
    offer.url                = campaign.url
    offer.requirement        = campaign.requirement
    offer.requirement_detail = campaign.requirement_detail
    offer.period             = campaign.period

    #advertisement = campaign.advertisements[0]
    offer.price              = campaign.price
    offer.payment            = campaign.payment
    if campaign.point.nil?
      # TODO: デフォルト還元率の処理
      offer.point            = 10
    else
      offer.point            = campaign.point
    end

    return offer
  end

  def equal?(campaign)
    # チェックするオブジェクトの量もそんなに多くならないので、とりあえずは全部を愚直にチェック
    if campaign_category != campaign.campaign_category
      return false
    end

    if name != campaign.name
      return false
    end

    if detail != campaign.detail
      return false
    end

    if icon_url != campaign.icon_url
      return false
    end

    if url != campaign.url
      return false
    end

    if requirement != campaign.requirement
      return false
    end

    if requirement_detail != campaign.requirement_detail
      return false
    end

    if period != campaign.period
      return false
    end

    if price != campaign.price
      return false
    end

    if payment != campaign.payment
      return false
    end

    # TODO: デフォルト還元率の処理
    if point != campaign.point
      return false
    end

    return true
  end
end
