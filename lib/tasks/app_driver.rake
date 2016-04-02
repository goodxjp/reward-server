# -*- coding: utf-8 -*-
require 'nokogiri'
require 'open-uri'
require 'kconv'

namespace :app_driver do
  #
  # Get AppDriver
  #
  desc "Get AppDriver data"
  task :get => :environment do
    campaign_source = CampaignSource.find(NetworkSystemAppDriver::CS_ID_KOYUBI)
    campaign_source.lock!

    config = AppDriverConfig.find_by(campaign_source: campaign_source)
    if config.nil?
      puts "Config null error."
      next
    end

    # 本番データ
    site_id = config.site_identifier
    media_id = config.media_identifier
    site_key = config.site_key
    uri_string = "http://ads.appdriver.jp/4.1.#{site_id}ads"

    document = NetworkSystemAppDriver.get_campaigns(uri_string, site_id, media_id, site_key)
    #File.write("app_driver.xml", document)  # デバッグ用
    create_ns_campaigns, update_ns_campaigns, delete_ns_campaigns = NetworkSystemAppDriver.register_campaigns(campaign_source, document)

    # 追加されたネットワーク独自キャンペーンのうち、明らかに Android 登録案件のものを登録
    # TODO: seeds.rb に依存しないようにしたい。seeds の値をどこかに定数化するしかないかも。
    create_ns_campaigns.each do |nsc|
      if nsc.auto_register?
        campaign = nsc.new_campaign  # まだカテゴリが決定できていない
        campaign.campaign_category_id = 1  # seeds.rb 依存
        campaign.point = (campaign.payment * Setting.reduction_rate(Time.zone.now)).floor  # 9 割固定
        ActiveRecord::Base.transaction do
          campaign.media << Medium.find(1)  # seeds.rb 依存
          campaign.update_related_offers
        end
      end
    end

    # 削除されたネットワーク独自キャンペーンに対応するキャンペーンを無効にする
    delete_ns_campaigns.each do |nsc|
      # 対応するキャンペーン
      campaign = nsc.corresponding_campaign

      if not campaign.nil?
        # 対応キャンペーンを無効に
        ActiveRecord::Base.transaction do
          campaign.update(available: false)
          campaign.update_related_offers
        end
      end
    end

    # レポートメール送信 (結構、頻繁に上げ下げされるので、削除したものはレポートメールで送らない)
    #if create_ns_campaigns.size > 0 or delete_ns_campaigns.size > 0
    if create_ns_campaigns.size > 0
      AdminUserMailer.report_app_driver_get(create_ns_campaigns).deliver
    end

  end

  # チェックのみでデータの変更は行わないこと！
  desc "Cehck AppDriver data"
  task :check => :environment do
    # TODO
  end
end
