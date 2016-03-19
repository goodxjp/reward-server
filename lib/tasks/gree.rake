# -*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'kconv'

namespace :gree do
  # チェックのみでデータの変更は行わないこと！
  desc "Cehck GREE Ads Reward data"
  task :check => :environment do
    # 登録済みの GREE のキャンペーンを全てとってきてチェック
    # 無効データもチェックは将来的にはしないように (データが増えれば増えるほど重くなるので)。

    CAMPAIGN_SOURCE_ID_GREE_KOYUBI = 2

    campaign_source = CampaignSource.find(CAMPAIGN_SOURCE_ID_GREE_KOYUBI)
    campaign_source.lock!

    report_messages = []

    # 現在、有効な全てのキャンペーンの ID
    campaigns = Campaign.where(campaign_source: campaign_source)
    #campaigns = Campaign.where(campaign_source: campaign_source, available: true) # 将来的に
    campaigns.each do |c|
      gree_campaigns = GreeCampaign.where(campaign_source: c.campaign_source, campaign_identifier: c.source_campaign_identifier)
      if gree_campaigns.size > 1
        # TODO: エラー処理
        report_messages << "Campaign(#{c.id}) have too many coresponding GREE Campaign"
      end

      if gree_campaigns.size == 1
        gree_campaign = gree_campaigns[0]
      else
        gree_campaign = nil
        # 普通に GREE 案件データから登録していればあり得ない
        report_messages << "Campaign(#{c.id}) doesn't have coresponding GREE Campaign"
        next
      end

      #puts "##### #{c.id} #####"
      #puts c.name

      # GREE キャンペーンがミュートかどうかチェック
      mute = Mute.find_by(target: gree_campaign)
      if not mute.nil?
        next
      end

      # 有効、無効に不整合がないかチェック
      #puts c.available
      #puts gree_campaign.available
      if (c.available != gree_campaign.available)
        report_messages << "Campaign(#{c.id}) changes available #{gree_campaign.available} -> #{c.available}"
      end

      # 差分チェック
      # TODO: もっと詳しくチェック
      #puts c.payment
      #puts gree_campaign.thanks_media_revenue
      if (c.payment != gree_campaign.thanks_media_revenue)
        report_messages << "Campaign(#{c.id}) changes payment"
      end
    end

    puts report_messages

    # レポートメール送信
    if report_messages.size > 0
      AdminUserMailer.report_gree_check(report_messages).deliver
    end
  end
end
