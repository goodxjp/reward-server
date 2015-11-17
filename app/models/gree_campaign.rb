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
end
