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
    NetworkSystemAppDriver.register_campaigns(campaign_source, document)
  end
end
