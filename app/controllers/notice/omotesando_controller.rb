# -*- coding: utf-8 -*-
module Notice
  class OmotesandoController < NoticeController
    #
    # adcrops
    #
    def adcrops
      #puts params

      #
      # 定数的なもの
      # - db/seeds.rb とあわせること
      #

      # メディア
      medium = Medium.find_by_id(1)
      if medium.nil?
        logger.fatal "Not found Medium(1)."
        render :nothing => true, :status => 404 and return
      end

      # キャンペーンソース
      campaign_source = CampaignSource.find_by_id(1)
      if campaign_source.nil?
        logger.fatal "Not found CampaignSource(1)."
        render :nothing => true, :status => 404 and return
      end

      #
      # IP アドレスのチェック
      #
      # TODO: IP アドレス確認
      if not (request.remote_ip == "127.0.0.1" or request.remote_ip == "1.21.148.73")
        logger.fatal "remote_ip is incorrect(#{request.remote_ip})."
        render :nothing => true, :status => 404 and return
      end

      # TODO: Active Model 化？
      suid   = params[:suid]
      xuid   = params[:xuid]
      sad    = params[:sad]
      xad    = params[:xad]
      cv_id  = params[:cv_id]
      reward = params[:reward]
      point  = params[:point]

      #
      # 通知ログの記録
      # - よっぽどの事 (DB に入らないデータ) がない限り残す。
      #
      notice = AdcropsAchievementNotice.new
      notice.campaign_source = campaign_source
      notice.suid   = suid
      notice.xuid   = xuid
      notice.sad    = sad
      notice.xad    = xad
      notice.cv_id  = cv_id
      notice.reward = reward
      notice.point  = point
      if not notice.save
        logger.error "Cannot save AdcropsAchievementNotice."
        render :nothing => true, :status => 404 and return
      end

      # 一意性の確認 (同一のもののパラメータは全て同じはず)
      # - すでに同じ ID の通知を処理していたら、処理しない。
      # TODO

      # キャンペーンとオファーの特定
      campaigns = Campaign.where(campaign_source: campaign_source, source_campaign_identifier: xad)
      if not campaigns.count == 1
        logger.error "Not found campaign(#{xad}). count = #{campaigns.count}"
        render :nothing => true, :status => 404 and return
      end
      campaign = campaigns[0]

      offer = Offer.find_by_id(sad)
      if offer.nil?
        logger.error "Not found offer(#{sad})."
        render :nothing => true, :status => 404 and return
      end

      # 念のためキャンペーンとオファーの関係をチェックしておく
      if not offer.campaign.id == campaign.id
        logger.error "Offer is inconsistent. offer.campaign.id = #{offer.campaign.id}, campaign.id = #{campaign.id}"
        render :nothing => true, :status => 404 and return
      end

      # 念のためオファーの報酬金額をチェック
      if not offer.payment == reward.to_i
        logger.error "Offer is inconsistent. offer.payment = #{offer.payment}, reward = #{reward}"
        render :nothing => true, :status => 404 and return
      end

      # ユーザーの特定
      media_user = MediaUser.find_by_id(suid)
      if media_user.nil?
        logger.error "Not found MediaUser(#{suid})."
        render :nothing => true, :status => 404 and return
      end

      # 念のためメディアのチェックをしておく
      if not media_user.medium.id == medium.id
        logger.error "MediaUser is inconsistent. media_user.medium.id = #{media_user.medium.id}, medium.id = #{medium.id}"
        render :nothing => true, :status => 404 and return
      end

      # 成果を付ける
      # TODO: トランザクションのテスト
      ActiveRecord::Base.transaction do
        # TODO: ロックのテスト
        media_user.lock!
        Achievement.add_achievement(media_user, campaign, reward.to_i, true, offer.point, @now, notice)
      end

      render :nothing => true, :status => 200
    end
  end
end
