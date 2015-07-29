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

      #
      # 同一成果の確認
      # - すでに同じ cv_id の通知を処理していたら、処理しない。
      #
      notices = AdcropsAchievementNotice.where(campaign_source: campaign_source, cv_id: cv_id)
      if notices.size > 1  # 保存した直後なので通常は 1 (無駄に成果を検索しないためにここでチェック)
        notices.each do |notice|
          achievements = Achievement.where(notification: notice)
          if achievements.size > 0
            logger.info "Retry notification achieved. (cv_id = #{cv_id})"
            logger.fatal "Too many Achievement notice.id = #{notice.id}." if achievements.size > 1
            render :nothing => true, :status => 200 and return
          else
            # 直前に保存した通知をチェックしてしまうので 1 回はこの表示がされてしまう。うーん、微妙。
            logger.info "Retry notification not achieved. (cv_id = #{cv_id})"
          end
        end
      end

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
      # TODO: いや、向こうで報酬金額の値を変更されて、うちで変更した値を取りにいってない場合は全然ありうる。
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

      # クリック履歴の確認
      click_histories = ClickHistory.where(media_user: media_user, offer: offer)
      if not click_histories.size > 0
        logger.error "Not found ClickHisotry (media_user.id = #{media_user.id}, offer.id = #{offer.id})."
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

    #
    # GREE Ads Reward
    #
    def gree
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
      campaign_source = CampaignSource.find_by_id(2)
      if campaign_source.nil?
        logger.fatal "Not found CampaignSource(2)."
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
      identifier       = params[:identifier]
      achieve_id       = params[:achieve_id]
      point            = params[:point]
      campaign_id      = params[:campaign_id]
      advertisement_id = params[:advertisement_id]
      media_session    = params[:media_session]

      #
      # 通知ログの記録
      # - よっぽどの事 (DB に入らないデータ) がない限り残す。
      #
      notice = GreeAchievementNotice.new
      notice.campaign_source  = campaign_source
      notice.identifier       = identifier
      notice.achieve_id       = achieve_id
      notice.point            = point
      notice.campaign_id      = campaign_id
      notice.advertisement_id = advertisement_id
      notice.media_session    = media_session
      if not notice.save
        logger.error "Cannot save GreeAchievementNotice."
        render :nothing => true, :status => 404 and return
      end

      #
      # 同一成果の確認
      # - すでに同じ achieve_id の通知を処理していたら、処理しない。
      #
      notices = GreeAchievementNotice.where(campaign_source: campaign_source, achieve_id: achieve_id)
      if notices.size > 1  # 保存した直後なので通常は 1 (無駄に成果を検索しないためにここでチェック)
        notices.each do |notice|
          achievements = Achievement.where(notification: notice)
          if achievements.size > 0
            logger.info "Retry notification achieved. (achieve_id = #{achieve_id})"
            logger.fatal "Too many Achievement notice.id = #{notice.id}." if achievements.size > 1
            render :nothing => true, :status => 200 and return
          else
            # 直前に保存した通知をチェックしてしまうので 1 回はこの表示がされてしまう。うーん、微妙。
            logger.info "Retry notification not achieved. (achieve_id = #{achieve_id})"
          end
        end
      end

      # achieve_id の処理だけでいいと思うが、
      # identifier, advertisement_id でチェックしろと仕様書にあるので、
      # 異なる achieve_id で identifier, advertisement_id が異なるというアホなものを
      # 送ってきたときにエラーで返してやる。
      notices = GreeAchievementNotice.where(identifier: identifier, advertisement_id: advertisement_id)
      if notices.size > 1  # 保存した直後なので通常は 1 (無駄に成果を検索しないためにここでチェック)
        # TODO
        # 「 DBクリア案件（※2） 」に対応するために、重複をチェックする期間は「 1日（00:00～23:59）（※3） 」にご設定いただくことを推奨致します。
        # とあるので、その通り実装してやるか。
      end

      source_campaign_identifier = campaign_id
      offer_id = media_session.to_i
      payment = point.to_i
      media_user_id = identifier.to_i

      # キャンペーンとオファーの特定
      campaigns = Campaign.where(campaign_source: campaign_source,
                                 source_campaign_identifier: source_campaign_identifier)
      if not campaigns.count == 1
        logger.error "Not found campaign(#{source_campaign_identifier}). count = #{campaigns.count}"
        render :nothing => true, :status => 404 and return
      end
      campaign = campaigns[0]

      offer = Offer.find_by_id(offer_id)
      if offer.nil?
        logger.error "Not found offer(#{offer_id})."
        render :nothing => true, :status => 404 and return
      end

      # 念のためキャンペーンとオファーの関係をチェックしておく
      if not offer.campaign.id == campaign.id
        logger.error "Offer is inconsistent. offer.campaign.id = #{offer.campaign.id}, campaign.id = #{campaign.id}"
        render :nothing => true, :status => 404 and return
      end

      # 念のためオファーの報酬金額をチェック
      # TODO: いや、向こうで報酬金額の値を変更されて、うちで変更した値を取りにいってない場合は全然ありうる。
      if not offer.payment == payment
        logger.error "Offer is inconsistent. offer.payment = #{offer.payment}, reward = #{payment}"
        render :nothing => true, :status => 404 and return
      end

      # ユーザーの特定
      media_user = MediaUser.find_by_id(media_user_id)
      if media_user.nil?
        logger.error "Not found MediaUser(#{media_user_id})."
        render :nothing => true, :status => 404 and return
      end

      # 念のためメディアのチェックをしておく
      if not media_user.medium.id == medium.id
        logger.error "MediaUser is inconsistent. media_user.medium.id = #{media_user.medium.id}, medium.id = #{medium.id}"
        render :nothing => true, :status => 404 and return
      end

      # クリック履歴の確認
      click_histories = ClickHistory.where(media_user: media_user, offer: offer)
      if not click_histories.size > 0
        logger.error "Not found ClickHisotry (media_user.id = #{media_user.id}, offer.id = #{offer.id})."
        render :nothing => true, :status => 404 and return
      end

      # 成果を付ける
      # TODO: トランザクションのテスト
      ActiveRecord::Base.transaction do
        # TODO: ロックのテスト
        media_user.lock!
        Achievement.add_achievement(media_user, campaign, payment, true, offer.point, @now, notice)
      end

      render :nothing => true, :status => 200
    end
  end
end
