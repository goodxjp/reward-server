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

  def get_url_for_campaign
    GreeCampaign.change_url(click_url)
  end

  def self.change_url(click_url)
    # TODO: もと URL の不正を検知できるように
    click_url.sub!(/_identifier=/, "identifier=$USER_ID$")
    click_url.sub!(/digest=(\w+)/, "digest=$GREE_DIGEST$")
    click_url << "&_media_session=$OFFER_ID$"
  end

  #
  # 対応するキャンペーン取得
  #
  def corresponding_campaign
    campaigns = Campaign.where(campaign_source: campaign_source, source_campaign_identifier: campaign_identifier)
    if campaigns.size > 1
      logger_fatal "Campaigns are duplication. (campaign_source = #{campaign_source}, source_campaign_identifier =  #{campaign_identifier} )"
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
    campaign.network_id = NetworkSystemGree::NETWORK_ID
    campaign.campaign_source = campaign_source
    campaign.source_campaign_identifier = campaign_identifier

    campaign.name = site_name
    campaign.detail = site_description
    campaign.icon_url = icon_url
    campaign.url = get_url_for_campaign
    campaign.requirement = default_thanks_name
    campaign.requirement_detail = draft
    if thanks_thanks_period == 0
      campaign.period = "10 分程度"
    else
      campaign.period = "#{thanks_thanks_period} 日程度"
    end
    campaign.price = site_price
    campaign.payment = thanks_media_revenue
    campaign.payment_is_including_tax = true
  end
end
