# -*- coding: utf-8 -*-
class NetworkSystemGree < NetworkSystem
  def self.make_gree_digest_for_redirect_url(campaign, media_user)
    # メディア ID と siteKey はキャンペーンソースによって変わるので DB に保存
    config = GreeConfig.find_by(campaign_source: campaign.campaign_source)
    if config == nil
      return nil
    end

    return make_gree_digest(campaign, media_user, config.media_identifier, config.site_key)
  end

  def self.make_gree_digest(campaign, media_user, media_id, site_key)
    campaign_id = campaign.source_campaign_identifier
    identifier = media_user.id

    return (Digest::SHA256.hexdigest "#{campaign_id};#{identifier};#{media_id};#{site_key}").upcase
  end

  #
  # 案件取得関連
  #
  def self.get_campaigns(uri_string, site_id, media_id, key)
    request_time = Time.zone.now.to_i
    digest = Digest::SHA256.hexdigest "#{site_id}:#{request_time}:#{key}"

    uri = URI(uri_string)
    uri.query = { site_id: site_id, media_id: media_id, request_time: request_time, digest: digest, delivery: 2 }.to_param
    #puts uri.to_s

    document = open(uri, &:read).toutf8

    return document
  end

  def self.register_campaigns(campaign_source, document)
    json = JSON.parse(document)

    # 現在、有効な全ての GREE キャンペーン ID
    # ここから取得データにあったものを消していき、残ったものが無効になったキャンペーン
    current_ids = GreeCampaign.where(campaign_source: campaign_source,
                                     available: true).ids
    puts "current_ids.size = #{current_ids.size}"

    # TODO: JSON データにエラーがあったときのパターンをもっと真面目に処理
    ActiveRecord::Base.transaction do
      json['result'].each do |o|
        campaign_identifier = o['campaign_id'].to_s

        # 既存の GREE キャンペーンを取得 (無効なものもあるかもしれないので一度取り直す)
        gree_campaigns = GreeCampaign.where(campaign_source: campaign_source,
                                            campaign_identifier: campaign_identifier)

        if (gree_campaigns.size == 0)
          campaign = GreeCampaign.new
        elsif (gree_campaigns.size > 1)
          # TODO: タスクの共通関数どうするか？
          #logger_fatal ""
          logger.fatal "[FATAL] GREE campaign data is wrong (campaign_id = #{campaign_identifier})."
          next
        else
          campaign = gree_campaigns[0]
        end

        thanks = o['thanks'][0]

        puts "-------- ^ ----------------------------------------"
        puts o['campaign_id']
        puts o['site_name']
        puts o['thanks'].size
        puts thanks['media_revenue']
        puts thanks['thanks_name']
        puts "-------- $ ----------------------------------------"

        campaign.campaign_source = campaign_source

        campaign.site_price= o['site_price']
        campaign.icon_url = o['icon_url']

        campaign.thanks_count = o['thanks'].size
        campaign.thanks_media_revenue = thanks['media_revenue']
        campaign.thanks_thanks_name = thanks['thanks_name']
        campaign.thanks_thanks_point = thanks['thanks_point']
        campaign.thanks_thanks_category = thanks['thanks_category']
        campaign.thanks_thanks_period = thanks['thanks_period']

        campaign.campaign_identifier = o['campaign_id']
        campaign.subscription_duration = o['subscription_duration']
        campaign.carrier = o['carrier']
        campaign.start_time = Time.zone.parse(o['start_time'])
        campaign.end_time = Time.zone.parse(o['end_time'])
        campaign.is_url_scheme = o['is_url_scheme']
        campaign.site_price_currency = o['site_price_currency']
        campaign.site_description = o['site_description']
        campaign.site_name = o['site_name']
        campaign.campaign_category = o['campaign_category']
        campaign.market_app_id = o['market_app_id']
        campaign.click_url = o['click_url']
        campaign.default_thanks_name = o['default_thanks_name']
        campaign.number_of_max_action_daily = o['number_of_max_action_daily']
        campaign.daily_action_left_in_stock = o['daily_action_left_in_stock']
        campaign.number_of_max_action = o['number_of_max_action']
        campaign.draft = o['draft']
        campaign.platform_identifier = o['platform_id']
        campaign.duplication_type = o['duplication_type']
        campaign.duplication_date = o['duplication_date']

        campaign.available = true

        campaign.save!

        current_ids.delete(campaign.id)
      end

      # 取得データに入ってなかった有効なキャンペーンを全て無効に
      puts "Turn to invalid. current_ids = #{current_ids.to_s}"
      # TODO: 更新日時が更新されない。
      #GreeCampaign.where(id: current_ids).update_all("available = false")
      GreeCampaign.where(id: current_ids).each do |gc|
        gc.update(available: false)
      end
    end
  end
end
