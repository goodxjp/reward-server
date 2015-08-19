# -*- coding: utf-8 -*-
class MediaUsersController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_media_user, only: [:show, :edit, :update, :destroy, :add_point_by_campaign, :add_point_by_offer]

  def index
    @media_users = MediaUser.order(id: :desc).page params[:page]
  end

  def show
    # 各履歴取得
    @point_histories = PointHistory.where(media_user: @media_user).order(created_at: :desc)
    @click_histories = ClickHistory.where(media_user: @media_user).order(created_at: :desc)

    # ポイント資産 (ここは案件管理者には見せない？！)
    @points = Point.where(media_user: @media_user).order(created_at: :desc)
  end

  def destroy
    @media_user.destroy
    redirect_to media_users_url, notice: 'MediaUser was successfully destroyed.'
  end

  def notify
    @media_user = MediaUser.find(params[:id])
    api_key = ENV['API_KEY']
    registration_ids = [ @media_user.android_registration_id ]
    gcm = GCM.new(api_key)
    options = { data: { message: "通知のテスト" }, collapse_key: "test" }
    response = gcm.send_notification(registration_ids, options)

    head :no_content
  end

  def add_point_by_offer
    offer = Offer.find(params[:offer_id])
    campaign = offer.campaign

    # TODO: エラー処理
    #add_point(@media_user, offer.point, PointType::MANUAL, campaign)
    # TODO: キャンペーンの税込、税抜きに対応する
    Achievement.add_achievement(@media_user, campaign, campaign.payment, true, campaign.point, Time.zone.now, nil)

    redirect_to :action => :show
  end

  # 手動成果
  def add_point_by_campaign
    campaign = Campaign.find(params[:campaign_id])

    # TODO: エラー処理
    #add_point(@media_user, campaign.advertisements[0].point, PointType::MANUAL, campaign)
    # TODO: キャンペーンの税込、税抜きに対応する
    Achievement.add_achievement(@media_user, campaign, campaign.payment, true, campaign.point, Time.zone.now, nil)

    redirect_to :action => :show
  end

  # ポイント追加の処理はメディアユーザーに共通化
  # メディアユーザーの変更は許さない。
  # キャンペーンが途中で変わってることがあるので注意。
  def add_point(media_user, point, type, campaign)
    media_user.lock!
    # TODO: 悲観的ロックに失敗した場合の処理

    p = Point.new()  # 数値の point と被るので、変数名を p に
    p.media_user    = media_user
    p.type          = type
    p.source        = campaign  # 手動の時はキャンペーンに対してつける。自動の時は成果に対して付けた方がいい？
    p.point         = point
    p.remains       = p.point
    p.expiration_at = nil  # TODO: 現在は期限なし

    point_history = PointHistory.new()
    point_history.media_user   = media_user
    point_history.point_change = point
    point_history.detail       = campaign.name
    point_history.source       = p

    media_user.point       = media_user.point       + point
    media_user.total_point = media_user.total_point + point

    ActiveRecord::Base.transaction do
      p.save!
      point_history.save!
      media_user.save!
    end
      return
    rescue => e
      # TODO: エラー処理
      logger.debug e
      return
  end

  private
    def set_media_user
      @media_user = MediaUser.find(params[:id])
    end

    def media_user_params
      params.require(:media_user).permit(:terminal_id, :terminal_info, :android_registration_id)
    end
end
