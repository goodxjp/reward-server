# -*- coding: utf-8 -*-
module Notice
  class MediaController < NoticeController
    #
    # adcrops
    #
    def adcrops
      #puts params

      # IP アドレスのチェック
      # TODO: IP アドレス確認
      if not request.remote_ip == "127.0.0.1"
        logger.fatal "remote_ip is incorrect(#{request.remote_ip})."
        render :nothing => true, :status => 404 and return
      end

      medium = Medium.find_by_id(params[:id])
      if medium.nil?
        logger.fatal "Not found media(#{params[:id]})."
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
      #
      # - よっぽどの事 (通信ログに残せないほどめちゃくちゃなデータ) 以外は残す。
      #
      # TODO

      # 一意性の確認 (同一のもののパラメータは全て同じはず)
      # - すでに同じの通知を処理していたら、処理しない。
      # TODO

      # キャンペーン、オファーの特定
      campaigns = Campaign.where(campaign_source_id: 2, source_campaign_identifier: xad)
      # ここの値は DB とあわせておく必要がある。
      # TODO: どうするのがいいか？
      if not campaigns.count == 1
        logger.error "Not found campaign(#{xad}). count = #{campaigns.count}"
        render :nothing => true, :status => 400 and return
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
        render :nothing => true, :status => 400 and return
      end

      # 念のためオファーの報酬金額をチェック
      if not offer.payment == reward.to_i
        logger.error "Offer is inconsistent. offer.payment = #{offer.payment}, reward = #{reward}"
        render :nothing => true, :status => 400 and return
      end

      # ユーザーの特定
      media_user = MediaUser.find_by_id(suid)
      if media_user.nil?
        logger.error "Not found media_user(#{suid})."
        render :nothing => true, :status => 400 and return
      end

      # 念のためメディアのチェックをしておく
      if not media_user.medium.id == medium.id
        logger.error "MediaUser is inconsistent. media_user.medium.id = #{media_user.medium.id}, medium.id = #{medium.id}"
        render :nothing => true, :status => 400 and return
      end

      # 成果を付ける
      Achievement.add_achievement(media_user, campaign, reward, true, offer.point, @now, nil)  # TODO 最後の引数

      #
      # 通知ログの更新
      #
      # - 失敗した場合は更新しない
      #
      # TODO

      render :nothing => true, :status => 200
    end
  end
end
