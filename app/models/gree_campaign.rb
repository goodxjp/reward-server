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
end
