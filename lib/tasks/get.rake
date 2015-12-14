require 'nokogiri'
require 'open-uri'
require 'kconv'

namespace :get do
  #
  # Get GREE Ads
  #
  desc "Get GREE Ads data"
  task :gree => :environment do
    CAMPAIGN_SOURCE_ID_GREE_KOYUBI = 2

    campaign_source = CampaignSource.find(CAMPAIGN_SOURCE_ID_GREE_KOYUBI)
    campaign_source.lock!
    # TODO: なぜかトランザクションの外ではロックされない？

    config = GreeConfig.find_by(campaign_source: campaign_source)
    if config.nil?
      puts "Config null error."
      return
    end

    # 本番データ
    site_id = config.site_identifier
    media_id = config.media_identifier
    key = config.site_key
    uri_string = "https://reward.gree.net/api.rest/2/p/get_campaigns.1"
    # TODO: 設定化

    document = NetworkSystemGree.get_campaigns(uri_string, site_id, media_id, key)
    #puts document
    #File.write("gree.json", JSON.pretty_generate(JSON.parse(document)))
    create_gree_campaigns, update_gree_campaigns, delete_gree_campaigns = NetworkSystemGree.register_campaigns(campaign_source, document)

    # TODO: ロック解除する必要ある？

    # 削除になったもののうち、登録済みのもののみ残す (対応キャンペーンを無効にしてしまう)
    delete_gree_campaigns.each do |gc|
      # 対応するキャンペーン
      campaign = gc.corresponding_campaign

      if campaign.nil?
        delete_gree_campaigns.delete(gc)
      else
        # 対応キャンペーンを無効に
        ActiveRecord::Base.transaction do
          campaign.update(available: false)
          campaign.update_related_offers
        end
      end
    end

    # レポートメール送信
    if create_gree_campaigns.size > 0 or delete_gree_campaigns.size > 0
      AdminUserMailer.report_get_gree(create_gree_campaigns, delete_gree_campaigns).deliver
    end
  end

  #
  # Get GREE Ads (Test)
  #
  desc "Get GREE Ads data (for Test)"
  task :gree_test => :environment do
    CAMPAIGN_SOURCE_ID_GREE_KOYUBI = 2

    campaign_source = CampaignSource.find(CAMPAIGN_SOURCE_ID_GREE_KOYUBI)
    campaign_source.lock!
    # TODO: なぜかトランザクションの外ではロックされない？

    config = GreeConfig.find_by(campaign_source: campaign_source)
    if config.nil?
      puts "Config null error."
      return
    end

    # テスト用データ
    site_id = 9324
    media_id = 1318
    key = "e77aa5facba56d6c331bb5a827705f18"
    uri_string = "https://reward-sb.gree.net/api.rest/2/p/get_campaigns.1"

    document = NetworkSystemGree.get_campaigns(uri_string, site_id, media_id, key)
    #puts document
    #File.write("gree.json", JSON.pretty_generate(JSON.parse(document)))
    create_gree_campaigns, update_gree_campaigns, delete_gree_campaigns = NetworkSystemGree.register_campaigns(campaign_source, document)
    puts create_gree_campaigns.size
    puts update_gree_campaigns.size
    puts delete_gree_campaigns.size

    # TODO: ロック解除する必要ある？

    # 削除になったもののうち、登録済みのもののみ残す (対応キャンペーンを無効にしてしまう)
    delete_gree_campaigns.each do |gc|
      # 対応するキャンペーン
      campaign = gc.corresponding_campaign

      if campaign.nil?
        delete_gree_campaigns.delete(gc)
      else
        # 対応キャンペーンを無効に
        ActiveRecord::Base.transaction do
          campaign.update(available: false)
          campaign.update_related_offers
        end
      end
    end

    # レポートメール送信
    if create_gree_campaigns.size > 0 or delete_gree_campaigns.size > 0
      AdminUserMailer.report_get_gree(create_gree_campaigns, delete_gree_campaigns).deliver
    end
  end

  #
  # Get au SmartPass
  #
  desc "Get au SmartPass data from RewardPlatform (for Sample)"
  task :au => :environment do
    uri = URI("http://rewardplatform.jp/goldtaro/210141/")
    user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12A365 Safari/600.1.4"

    html = open(uri, 'User-Agent' => user_agent, &:read).toutf8
    #File.write(Rails.root.join('au.html'), html)

    doc = Nokogiri.HTML(html)

    # 現在、有効な全てのキャンペーンの ID
    current_ids = Campaign.where(campaign_source_id: 1, available: true).ids
    puts "current_ids.size = #{current_ids.size}"

    ActiveRecord::Base.transaction do
      doc.xpath("//div[@class='item_info']").each do |node|
        h3 = node.css("h3").first.content
        img_src = node.css("img").first['src']
        inst_href = node.css(".inst a").first['href']
        id = inst_href.scan(/\?c=([0-9]+)&/)[0][0].to_i

        puts h3
        puts img_src
        puts inst_href
        puts id

        campaigns = Campaign.where(campaign_source_id: 1, source_campaign_identifier: id.to_s)

        if (campaigns.size == 0)
          campaign = Campaign.new
        else
          campaign = campaigns[0]
        end

        # 適当にキャンペーンデータ作ってる
        campaign.network_id = 2
        campaign.campaign_source_id = 1
        campaign.source_campaign_identifier = id

        campaign.campaign_category_id = 2
        campaign.name = h3
        campaign.detail = "#{h3} (au スマパス案件を自動チェックするための嘘キャンペーン)"
        campaign.icon_url = "http://rewardplatform.jp#{img_src}"
        campaign.url = "http://rewardplatform.jp#{inst_href}"
        campaign.price = 0
        campaign.payment = id % 1234

        campaign.requirement = "どうやっても無理"
        campaign.requirement_detail = "そんな簡単に成果がつくと思ったら大間違い。"
        campaign.period = "3 年程度"

        campaign.available = true
        campaign.save!

        current_ids.delete(campaign.id)
      end

      # 取得データに入ってなかった有効なキャンペーンを全て無効に
      puts "current_ids.size = #{current_ids.size}"
      Campaign.where(id: current_ids).update_all("available = false")
    end
  end
end
