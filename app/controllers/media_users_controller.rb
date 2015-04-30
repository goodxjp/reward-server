# -*- coding: utf-8 -*-
class MediaUsersController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_media_user, only: [:show, :edit, :update, :destroy, :add_point_by_campaign]
  skip_before_filter :verify_authenticity_token, :only => [ :create ]

  def index
    @media_users = MediaUser.order(id: :desc)
  end

  def show
    # クリック履歴取得
    @click_histories = ClickHistory.where(media_user: @media_user).order(created_at: :desc)
    @points = Point.where(media_user: @media_user).order(created_at: :desc)
  end

  # TODO: 廃止
  def create
    @media_user = MediaUser.new(media_user_params)

    terminal_info = params[:media_user][:terminal_info]
    @media_user.terminal_info = terminal_info.to_json

    if @media_user.save
      render json: @media_user
      return
    end
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

  # クリック履歴に対してポイントをつけようとも思ったが、
  # クリック履歴に無関係な成果を付ける可能性もあるので、ここに定義
  # TODO: Point モデルの POST にした方がいいかも。
  def add_point_by_campaign
    @campaign = Campaign.find(params[:campaign_id])

    point = Point.new()
    point.media_user = @media_user
    point.source = @campaign
    point.point = @campaign.advertisements[0].point  # オファーベースがよい？
    point.type = PointType::MANUAL

    if point.save
      # TODO: このメソッドを Ajax でできないか
      redirect_to :action => :show
    else
      # TODO: エラー処理
      redirect_to :action => :show
    end
  end

  private
    def set_media_user
      @media_user = MediaUser.find(params[:id])
    end

    def media_user_params
      params.require(:media_user).permit(:terminal_id, :terminal_info, :android_registration_id)
    end
end
