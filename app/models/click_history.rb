# -*- coding: utf-8 -*-
class ClickHistory < ActiveRecord::Base
  belongs_to :media_user
  belongs_to :offer

  def user_agent
    begin
      json = JSON.parse(request_info)
    #rescue JSON::ParserError => e
    rescue Exception => e
      logger.debug(e)
      return nil
    end
    return json["user_agent"]
  end

  #
  # メディアユーザーのキャンペーンに対するクリック履歴を取得する
  #
  def self.find_all_by_media_user_and_campaign(media_user, campaign)
    # 対象オファーを全部取得
#    ids = Offer.where(campaign: campaign).ids
#    click_histories = ClickHistory.where(media_user: media_user, offer: ids)
    click_histories = ClickHistory.where(media_user: media_user, offer: Offer.where(campaign: campaign))

    click_histories
  end
end
