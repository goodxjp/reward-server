# -*- coding: utf-8 -*-
#
# AppDriver キャンペーン
#
class AppDriverCampaign < ActiveRecord::Base
  belongs_to :campaign_source

  #
  # Validator
  #
  validates :campaign_source,
    presence: true

  #
  # ネットワークシステム別キャンペーン取得
  #
  def self.get_ns_campaign(campaign_source, ns_campaign_id)
    ns_campaigns = AppDriverCampaign.where(campaign_source: campaign_source,
                                           identifier: ns_campaign_id)

    case ns_campaigns.size
    when 0
      ns_campaign = nil
    when 1
      ns_campaign = ns_campaigns[0]
    else
      LogUtil.fatal "AppDriver campaign data is wrong (identifier = #{ns_campaign_id})."
      ns_campaign = ns_campaigns[0]  # とりあえず、一つ目のデータで動かしておく
    end

    ns_campaign
  end

  def self.change_url(url)
    # TODO: もと URL の不正を検知できるように
    url.sub!(/_identifier=/, "_identifier=$USER_ID$")
  end

  def get_url_for_campaign
    self.class.change_url(location)
  end

  #
  # 対応するキャンペーン取得
  #
  def corresponding_campaign
    campaigns = Campaign.where(campaign_source: campaign_source, source_campaign_identifier: identifier)
    if campaigns.size > 1
      LogUtil.fatal "Campaigns are duplication. (campaign_source = #{campaign_source}, source_campaign_identifier =  #{identifier} )"
      campaign = nil
      # TODO: 例外返した方がいい？
    elsif campaigns.size == 1
      campaign = campaigns[0]
    else
      campaign = nil
    end

    campaign
  end

  #
  # キャンペーン生成
  #
  def new_campaign
    campaign = Campaign.new

    set_campaign(campaign)

    campaign
  end

  def set_campaign(campaign)
    campaign.network_id = NetworkSystemAppDriver::NETWORK_ID
    campaign.campaign_source = campaign_source
    campaign.source_campaign_identifier = identifier

    campaign.name = name
    campaign.detail = detail
    campaign.icon_url = icon
    campaign.url = get_url_for_campaign
    campaign.requirement = advertisement_name
    campaign.requirement_detail = remark
    if subscription_duration == 0
      campaign.period = "10 分程度"
    else
      campaign.period = "#{subscription_duration} 日程度"
    end
    campaign.price = price
    campaign.payment = advertisement_payment
    campaign.payment_is_including_tax = false
  end
end
