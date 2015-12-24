# -*- coding: utf-8 -*-
module Notice
  class OmotesandoController < NoticeController
    # この通知はこゆび太郎用
    # メディア ID (db/seeds.rb とあわせること)
    MEDIA_ID_KOYUBI = 1

    #
    # adcrops
    #
    def adcrops
      #
      # 定数的なもの
      # - db/seeds.rb とあわせること
      #

      # メディア
      medium = Medium.find(MEDIA_ID_KOYUBI)

      # キャンペーンソース
      campaign_source = CampaignSource.find(1)

      # TODO: 要確認
      # 許可 IP アドレス
      allow_from = [ "127.0.0.1", "1.21.148.73" ]

      #
      # IP アドレスのチェック
      #
      if not allow_from.include?(request.remote_ip)
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
        logger_fatal "Cannot save AdcropsAchievementNotice."
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

      # 値の対応関係
      source_campaign_identifier = xad
      offer_id = sad.to_i
      payment = reward.to_i
      payment_is_including_tax = true
      media_user_id = suid.to_i

      #
      # 共通処理
      #
      if check_and_add_achievement(medium, campaign_source,
                                   source_campaign_identifier, offer_id, payment, payment_is_including_tax,
                                   media_user_id, @now, notice)
        render :nothing => true, :status => 200
      else
        render :nothing => true, :status => 404
      end
    end

    #
    # GREE Ads Reward
    #
    def gree
      #
      # 定数的なもの
      # - db/seeds.rb とあわせること
      #

      # メディア
      medium = Medium.find(MEDIA_ID_KOYUBI)

      # キャンペーンソース
      campaign_source = CampaignSource.find(2)

      # TODO: 余裕があったら、sandbox 環境と本番環境のチェックを厳密に
      # 動作環境ごとに手軽に値を変える、管理できる仕組み
      # 許可 IP アドレス
      allow_from = [ "127.0.0.1", "1.21.148.73", "210.140.181.7", "210.140.181.3", "210.140.181.32" ]

      #
      # IP アドレスのチェック
      #
      if not allow_from.include?(request.remote_ip)
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
        logger_fatal "Cannot save GreeAchievementNotice."
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
            logger_fatal "Too many Achievement notice.id = #{notice.id}." if achievements.size > 1
            # 正常で返す
            render_gree_added_point and return
          else
            # 直前に保存した通知をチェックしてしまうので 1 回はこの表示がされてしまう。うーん、微妙。
            logger.info "Retry notification not achieved. (achieve_id = #{achieve_id})"
          end
        end
      end

      # achieve_id の処理だけでいいと思うが、
      # advertisement_id, itentifier でチェックしろと仕様書にあるので、重複の時にエラーで返す。
      notices = GreeAchievementNotice.where(identifier: identifier, advertisement_id: advertisement_id)
      if notices.size > 1  # 保存した直後なので通常は 1 (無駄に成果を検索しないためにここでチェック)
        # 「 DBクリア案件（※2） 」に対応するために、重複をチェックする期間は「 1日（00:00～23:59）（※3） 」にご設定いただくことを推奨致します。
        # とあるので、その通り実装してやるか。
        notices.each do |notice|
          achievements = Achievement.where(notification: notice)
          if achievements.size > 0 and @now.beginning_of_day <= notice.created_at and notice.created_at < @now.tomorrow.beginning_of_day
            logger.info "Similar notification achieved. (identifier = #{identifier}, advertisement_id = #{advertisement_id})"
            logger_fatal "Too many Achievement notice.id = #{notice.id}." if achievements.size > 1

            # エラーで返す
            render_gree_not_added_point and return
          else
            # 直前に保存した通知をチェックしてしまうので 1 回はこの表示がされてしまう。うーん、微妙。
            logger.info "Similar notification not achieved or far away. (identifier = #{identifier}, advertisement_id = #{advertisement_id})"
          end
        end

        # TODO: あまり厳密ではないが、どうせ、不要なチェックなので適当で OK
      end

      # 値の対応関係
      source_campaign_identifier = campaign_id
      offer_id = media_session.to_i
      payment = point.to_i
      payment_is_including_tax = true
      media_user_id = identifier.to_i

      #
      # 共通処理
      #
      if check_and_add_achievement(medium, campaign_source,
                                   source_campaign_identifier, offer_id, payment, payment_is_including_tax,
                                   media_user_id, @now, notice)
        render_gree_added_point
      else
        render_gree_not_added_point
      end
    end

    #
    # AppDriver
    #
    def app_driver
      #
      # 定数的なもの
      #

      # メディア
      medium = Medium.find(MEDIA_ID_KOYUBI)

      # キャンペーンソース
      campaign_source = CampaignSource.find(NetworkSystemAppDriver::CS_ID_KOYUBI)

      # 許可 IP アドレス
      allow_from = [ "127.0.0.1", "59.106.111.156", "27.110.48.28", "59.106.111.152", "27.110.48.24" ]

      # TODO: IP アドレスのチェックを共通化 (まずはキャッシュの仕組みを作ってから)
      #
      # IP アドレスのチェック
      #
      if not allow_from.include?(request.remote_ip)
        LogUtil.fatal "remote_ip is incorrect(#{request.remote_ip})."
        render :nothing => true, :status => 404 and return
      end

      identifier         = params[:identifier]
      achieve_id         = params[:achieve_id]
      accepted_time      = params[:accepted_time]
      campaign_id        = params[:campaign_id]
      campaign_name      = params[:campaign_name]
      advertisement_id   = params[:advertisement_id]
      advertisement_name = params[:advertisement_name]
      point              = params[:point]
      payment            = params[:payment]

      #
      # 通知ログの記録
      #
      # - よっぽどの事 (DB に入らないデータ) がない限り残す。
      #
      notice = AppDriverAchievementNotice.new
      notice.campaign_source    = campaign_source
      notice.identifier         = identifier
      notice.achieve_id         = achieve_id
      notice.accepted_time      = accepted_time
      notice.campaign_id        = campaign_id
      notice.campaign_name      = campaign_name
      notice.advertisement_id   = advertisement_id
      notice.advertisement_name = advertisement_name
      notice.point              = point
      notice.payment            = payment
      if not notice.save
        logger_fatal "Cannot save AppDriverAchievementNotice."
        render :nothing => true, :status => 404 and return
      end

      # TODO: ここでパラメータチェックをした方が安全かも
      # AppDriverAchievementNotice の Validation がいいかもと思ったけど、
      # 不正データも保存しておきたいので別メソッドで。

      #
      # 同一成果の確認
      # - すでに同じ achieve_id の通知を処理していたら、処理しない。
      #
      notices = AppDriverAchievementNotice.where(campaign_source: campaign_source, achieve_id: achieve_id)
                                          .where.not(id: notice.id)  # 直前に保存した通知は対象外
      notices.each do |notice|
        achievements = Achievement.where(notification: notice)
        if achievements.size > 0
          logger.info "Retry notification achieved. (achieve_id = #{achieve_id})"

          # 念のためデータ不整合チェック
          LogUtil.fatal "Too many Achievement notice.id = #{notice.id}." if achievements.size > 1

          # 正常で返す
          render_app_driver_added_point and return
        else
          logger.info "Retry notification not achieved. (achieve_id = #{achieve_id})"
        end
      end

      # achieve_id の処理だけでいいと思うが、
      # achieve_id, identifier でチェックしろと仕様書にある。identifier ごとに achieve_id 違うの？
      #notices = AppDriverAchievementNotice.where(identifier: identifier, achieve_id: achieve_id)

      # 値の対応関係
      source_campaign_identifier = campaign_id
      #offer_id = (わからない)
      payment = payment.to_i
      payment_is_including_tax = false
      media_user_id = identifier.to_i
      occurred_at = @now
      sales_at = Time.zone.parse(accepted_time)

      #
      # 共通処理
      #
      if check_and_add_achievement_without_offer(medium, campaign_source,
                                                 source_campaign_identifier, payment, payment_is_including_tax,
                                                 media_user_id, occurred_at, notice,
                                                 sales_at: sales_at)
        render_app_driver_added_point
      else
        render_app_driver_not_added_point
      end
    end

    private
      #
      # ネットワークシステムに依存しない処理 (オファーが特定できる場合)
      #
      def check_and_add_achievement(medium, campaign_source,
                                    source_campaign_identifier, offer_id, payment, payment_is_including_tax,
                                    media_user_id, occurred_at, notice,
                                    sales_at: nil)
        # キャンペーンとオファーの特定
        campaigns = Campaign.where(campaign_source: campaign_source,
                                   source_campaign_identifier: source_campaign_identifier)
        if not campaigns.count == 1
          logger_fatal "Not found campaign(#{source_campaign_identifier}). count = #{campaigns.count}"
          return false
        end
        campaign = campaigns[0]

        offer = Offer.find_by_id(offer_id)
        if offer.nil?
          logger_fatal "Not found offer(#{offer_id})."
          return false
        end

        # 念のためキャンペーンとオファーの関係をチェックしておく
        if not offer.campaign.id == campaign.id
          logger_fatal "Offer is inconsistent. offer.campaign.id = #{offer.campaign.id}, campaign.id = #{campaign.id}"
          return false
        end

        # 念のためオファーの報酬金額をチェック
        # 向こうで報酬金額を変更して、うちで変更した値を取りにいってないうちに、
        # ユーザーが案件を実行してしまった場合はこういうことが起こりうる。
        if not offer.payment == payment
          # 頻繁に起こるか様子を見るために FATAL でログを上げておく。
          logger_fatal "Offer is inconsistent. offer.payment = #{offer.payment}, payment = #{payment}"
          # エラー表示のみで、payment の値で売上を立てて、offer.point の値でポイントをつける。
        end

        # ユーザーの特定
        media_user = MediaUser.find_by_id(media_user_id)
        if media_user.nil?
          logger_fatal "Not found MediaUser(#{media_user_id})."
          return false
        end

        # 念のためメディアのチェックをしておく
        if not media_user.medium.id == medium.id
          logger_fatal "MediaUser is inconsistent. media_user.medium.id = #{media_user.medium.id}, medium.id = #{medium.id}"
          return false
        end

        # クリック履歴の確認
        click_histories = ClickHistory.where(media_user: media_user, offer: offer)
        if not click_histories.size > 0
          logger_fatal "Not found ClickHisotry (media_user.id = #{media_user.id}, offer.id = #{offer.id})."
          return false
        end

        # 成果を付ける
        # TODO: トランザクションのテスト
        ActiveRecord::Base.transaction do
          # TODO: ロックのテスト
          media_user.lock!
          # TODO: sales_at のテスト
          if sales_at.nil?
            Achievement.add_achievement(media_user, campaign, payment, payment_is_including_tax, offer.point, occurred_at,
                                        notification: notice)
          else
            Achievement.add_achievement(media_user, campaign, payment, payment_is_including_tax, offer.point, occurred_at,
                                        sales_at: sales_at, notification: notice)
          end
        end

        return true
      end

      #
      # ネットワークシステムに依存しない処理 (オファーが特定できない場合)
      #
      def check_and_add_achievement_without_offer(medium, campaign_source,
                                    source_campaign_identifier, payment, payment_is_including_tax,
                                    media_user_id, occurred_at, notice,
                                    sales_at: nil)
        # キャンペーンの特定
        campaigns = Campaign.where(campaign_source: campaign_source,
                                   source_campaign_identifier: source_campaign_identifier)
        if not campaigns.count == 1
          logger_fatal "Not found campaign(#{source_campaign_identifier}). count = #{campaigns.count}"
          return false
        end
        campaign = campaigns[0]

        # ユーザーの特定
        media_user = MediaUser.find_by_id(media_user_id)
        if media_user.nil?
          logger_fatal "Not found MediaUser(#{media_user_id})."
          return false
        end

        # オファーの特定 (付加ポイントを決定するためだけに利用)
        offer = find_appropriate_offer(media_user, campaign, payment)
        if offer.nil?
          # クリック履歴なし
          logger_fatal "Not found ClickHisotry (media_user.id = #{media_user.id}, campaign.id = #{campaign.id})."
          return false
        end

        # 念のためメディアのチェックをしておく
        if not media_user.medium.id == medium.id
          logger_fatal "MediaUser is inconsistent. media_user.medium.id = #{media_user.medium.id}, medium.id = #{medium.id}"
          return false
        end

        # クリック履歴はオファーの特定時に確認済み

        # 成果を付ける
        # TODO: トランザクションのテスト
        ActiveRecord::Base.transaction do
          # TODO: ロックのテスト
          media_user.lock!
          if sales_at.nil?
            Achievement.add_achievement(media_user, campaign, payment, payment_is_including_tax, offer.point, occurred_at,
                                        notification: notice)
          else
            Achievement.add_achievement(media_user, campaign, payment, payment_is_including_tax, offer.point, occurred_at,
                                        sales_at: sales_at, notification: notice)
          end
        end

        return true
      end

      #
      # 報酬金額から最適なオファー (実行時の表示していたと思われるオファー) を見つける
      #
      # - 報酬そのままで、ポイントを変更した後にクリックされて、その後に成果が来た場合に間違える。
      # - 先方で報酬変更された場合は、対象クリック履歴が見つからない場合がある。
      #
      def find_appropriate_offer(media_user, campaign, payment)
        click_histories = ClickHistory.find_all_by_media_user_and_campaign(media_user, campaign).order(created_at: :desc)

        if click_histories.size == 0
          return nil  # クリック履歴なし
        end

        # 1 人が 1 案件に対してクリックする数はたかがしれているので、全部まわす
        click_histories.each do |ch|
          if ch.offer.payment == payment
            # 最も最近にクリックされたオファーを返す
            return ch.offer
          end
        end

        # もし、報酬金額が同じクリック履歴が見つからなかったら、やむをえず最新のクリック履歴を使用する
        LogUtil.fatal "Not found Appropriate Offer (media_user.id = #{media_user.id}, campaign.id = #{campaign.id}, payment = #{payment})."
        return click_histories[0].offer
      end

      # GREE で「ポイント付与」の場合のレスポンス
      def render_gree_added_point
        render :text => "1", :status => 200
      end

      # GREE で「ポイント未付与」の場合のレスポンス (再送の必要がない)
      # 再送が必要の場合は 200 で返すべきではない
      def render_gree_not_added_point
        render :text => "0", :status => 200
      end

      # AppDriver で「ポイント付与」の場合のレスポンス
      def render_app_driver_added_point
        render :text => "1", :status => 200
      end

      # AppDriver で「ポイント未付与」の場合のレスポンス (再送の必要がない)
      # 再送が必要の場合は 200 で返すべきではない
      def render_app_driver_not_added_point
        render :text => "0", :status => 200
      end
  end
end
