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

    # TODO: 追加されたネットワーク独自キャンペーンのうち、明らかに Android 登録案件のものを登録

    # TODO: 削除されたネットワーク独自キャンペーンに対応するキャンペーンを無効にする

    # レポートメール送信
    if create_ns_campaigns.size > 0 or delete_ns_campaigns.size > 0
      AdminUserMailer.report_app_driver_get(create_ns_campaigns, delete_ns_campaigns).deliver
    end

  end

  # チェックのみでデータの変更は行わないこと！
  desc "Cehck AppDriver data"
  task :check => :environment do
    # TODO
  end
end
