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

    offer.price              = campaign.price
    offer.payment            = campaign.payment
    offer.payment_is_including_tax = campaign.payment_is_including_tax
    offer.point              = proper_point(campaign)

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

    if payment_is_including_tax != campaign.payment_is_including_tax
      return false
    end

    if point != Offer.proper_point(campaign)
      return false
    end

    return true
  end

  def self.proper_point(campaign)
    if campaign.point.nil?
      # デフォルト還元率
      reduction_rate = Config.reduction_rate(Time.zone.now)

      if campaign.payment_is_including_tax
        # 税込み
        return (campaign.payment * reduction_rate).round
      else
        # 税抜き
        # TODO: 税の切り替えタイミング注意！そんなに気にしなくてもいいかも
        ct_rate = Config.consumption_tax_rate(Time.zone.now)
        return (campaign.payment * (1 + ct_rate) * reduction_rate).round
      end
    else
      return campaign.point
    end
  end
end
