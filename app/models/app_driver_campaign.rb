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

  #
  # 対応するキャンペーン取得
  #
end
