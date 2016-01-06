# -*- coding: utf-8 -*-
#
# AppDriver システム
#
class NetworkSystemAppDriver
  # ネットワーク ID
  NETWORK_ID = 4

  # 新規メディアを登録するごとに追加する
  # キャンペーンソース ID
  CS_ID_KOYUBI = 3

  #
  # ネットワークシステム独自キャンペーン取得 (抽象メソッド実現)
  #
  def self.find_ns_campaign(ns_campaign_id)
    ns_campaign = AppDriverCampaign.find(ns_campaign_id)

    ns_campaign
  end

  #
  # ネットワークシステム独自キャンペーン取得 (抽象メソッド実現)
  #
  def self.get_ns_campaign_by_campaign(campaign)
    ns_campaigns = AppDriverCampaign.where(campaign_source: campaign.campaign_source, identifier: campaign.source_campaign_identifier)
    if ns_campaigns.size > 1
      LogUtil.fatal "AppDriverCampaign is incorrect. (identifier = #{campaign.source_campaign_identifier})"
      ns_campaign = ns_campaigns[0]
    elsif ns_campaigns.size == 1
      ns_campaign = ns_campaigns[0]
    else
      ns_campaign = nil
    end

    ns_campaign
  end

  #
  # 案件取得関連
  #
  def self.get_campaigns(uri_string, site_id, media_id, site_key)
    digest = Digest::SHA256.hexdigest "#{media_id}:#{site_key}"

    # http://qiita.com/QUANON/items/4a0a06e0ed76b9a07bc7
    uri = URI(uri_string)
    uri.query = { media_id: media_id, digest: digest }.to_param
    document = open(uri, &:read).toutf8
    #document = File.read("app_driver.xml", encoding: Encoding::UTF_8)  # デバッグ用

    return document
  end

  def self.register_campaigns(campaign_source, document)
    xml = Nokogiri::XML(document)

    # 現在、有効な全てのネットワークシステム別キャンペーン ID
    # ここから取得データにあったものを消していき、残ったものが無効になったキャンペーン
    current_ids = AppDriverCampaign.where(campaign_source: campaign_source,
                                          available: true).ids

    campaigns = xml.xpath("//campaign")
    campaigns.each do |xml_campaign|
      ns_campaign_id = xml_campaign.xpath("id").text

      # 既存のネットワークシステム独自キャンペーンを取得 (無効なものもあるかもしれないので一度取り直す)
      ns_campaign = AppDriverCampaign.get_ns_campaign(campaign_source, ns_campaign_id)

      if ns_campaign.nil?
        ns_campaign = AppDriverCampaign.new
      end

      # TODO: 毎回全部上書き → 変更があるのものみ上書き
      ns_campaign = xml_to_campaign(xml_campaign, campaign_source, ns_campaign)
      ns_campaign.available = true
      ns_campaign.save!

      current_ids.delete(ns_campaign.id)
    end

    # 取得データに入ってなかった有効なキャンペーンを全て無効に
    puts "Turn to invalid. current_ids = #{current_ids.to_s}"
    AppDriverCampaign.where(id: current_ids).each do |nsc|
      nsc.update(available: false)
    end
  end

  def self.xml_to_campaign(xml, campaign_source, campaign)
    campaign.campaign_source = campaign_source

    campaign.identifier = xml.xpath("id").text.to_i
    campaign.name = xml.xpath("name").text
    campaign.location = xml.xpath("location").text
    campaign.remark = xml.xpath("remark").text
    campaign.start_time = Time.zone.parse(xml.xpath("start_time").text)
    campaign.end_time = Time.zone.parse(xml.xpath("end_time").text)
    if xml.xpath("budget_is_unlimited").text == "true"
      campaign.budget_is_unlimited = true
    else
      campaign.budget_is_unlimited = false
    end
    campaign.detail = xml.xpath("detail").text
    campaign.icon = xml.xpath("icon").text
    campaign.url = xml.xpath("url").text
    campaign.platform = xml.xpath("platform").text.to_i
    if xml.xpath("market").text.blank?
      campaign.market = nil
    else
      campaign.market = xml.xpath("market").text.to_i
    end
    campaign.price = xml.xpath("price").text.to_i
    campaign.subscription_duration = xml.xpath("subscription_duration").text.to_i
    campaign.remaining = xml.xpath("remaining").text.to_i
    campaign.duplication_type = xml.xpath("duplication_type").text.to_i

    xml_advertisements = xml.xpath("advertisement")
    campaign.advertisement_count = xml_advertisements.size
    if xml_advertisements.size > 0
      xml_advertisement = xml_advertisements[0]
      campaign.advertisement_identifier = xml_advertisement.xpath("id").text.to_i
      campaign.advertisement_name = xml_advertisement.xpath("name").text
      campaign.advertisement_requisite = xml_advertisement.xpath("requisite").text.to_i
      campaign.advertisement_period = xml_advertisement.xpath("period").text.to_i
      campaign.advertisement_payment = xml_advertisement.xpath("payment").text.to_i
      campaign.advertisement_point = xml_advertisement.xpath("point").text.to_i
    end

    campaign
  end
end
