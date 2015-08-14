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
end
