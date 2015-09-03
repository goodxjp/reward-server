# -*- coding: utf-8 -*-
class MediaUsersController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_media_user, only: [:show, :edit, :update, :destroy, :notify, :add_point_by_offer]

  def index
    @media_users = MediaUser.order(id: :desc).page params[:page]
  end

  def show
    # 各履歴取得
    @point_histories = PointHistory.where(media_user: @media_user).order(created_at: :desc)
    @click_histories = ClickHistory.where(media_user: @media_user).order(created_at: :desc)

    # ポイント資産
    @points = Point.where(media_user: @media_user).order(created_at: :desc)
  end

  def destroy
    @media_user.destroy
    redirect_to media_users_url, notice: 'MediaUser was successfully destroyed.'
  end

  # 通知のテスト用
  # TODO: 未作成
  def notify
    api_key = ENV['API_KEY']
    registration_ids = [ @media_user.android_registration_id ]
    gcm = GCM.new(api_key)
    options = { data: { message: "通知のテスト" }, collapse_key: "test" }
    response = gcm.send_notification(registration_ids, options)

    head :no_content
  end

  # 手動成果
  def add_point_by_offer
    offer = Offer.find(params[:offer_id])

    ActiveRecord::Base.transaction do
      @media_user.lock!
      Achievement.add_dummy_achievement(@media_user, offer, Time.zone.now)
    end

    redirect_to action: :show
  end

  private
    def set_media_user
      @media_user = MediaUser.find(params[:id])
    end

    def media_user_params
      params.require(:media_user).permit(:terminal_id, :terminal_info, :android_registration_id)
    end
end
