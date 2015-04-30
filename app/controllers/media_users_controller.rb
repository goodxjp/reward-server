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

    # TODO: 他のポイント追加、ポイント消化が被ったときにダメダメ
    # TODO: 楽観的ロックじゃなく、ユーザーでロックかける。
    point = Point.new()
    point.media_user = @media_user
    point.source     = @campaign
    point.point      = @campaign.advertisements[0].point  # オファーベースでよい？
    point.type       = PointType::MANUAL

    @media_user.point       = @media_user.point       + point.point
    @media_user.total_point = @media_user.total_point + point.point

    # ポイント交換の機能を実装するまではトータルの成果を合計する
    sum_point = @media_user.points.sum(:point)
    @media_user.point       = sum_point + point.point
    @media_user.total_point = sum_point + point.point

    # TODO: ポイント追加処理を共通化 (ネットワーク経由の成果通知でも使用する)
    ActiveRecord::Base.transaction do
      point.save!
      @media_user.save!
    end
      # TODO: このメソッドを Ajax でできないか
      redirect_to :action => :show
    rescue => e
      # TODO: エラー処理
      logger.debug e
      redirect_to :action => :show
  end

  private
    def set_media_user
      @media_user = MediaUser.find(params[:id])
    end

    def media_user_params
      params.require(:media_user).permit(:terminal_id, :terminal_info, :android_registration_id)
    end
end
