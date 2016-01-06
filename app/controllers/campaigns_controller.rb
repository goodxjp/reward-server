# -*- coding: utf-8 -*-
class CampaignsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]

  # GET /campaigns
  # GET /campaigns.json
  def index
    @campaigns = Campaign.order(id: :desc).page params[:page]
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
    # 対応するネットワーク独自キャンペーン
    @source = @campaign.get_ns_campaign
  end

  # GET /campaigns/new
  def new
    if not params[:network_system_id].nil?
      network_system = NetworkSystem.find(params[:network_system_id])

      # ネットワークシステム独自キャンペーンを取得
      #ns_campaign = AppDriverCampaign.find(params[:ns_campaign_id])
      ns_campaign = network_system.find_ns_campaign(params[:ns_campaign_id])

      @campaign = ns_campaign.new_campaign
    else
      @campaign = Campaign.new
    end
  end

  # GET /campaigns/1/edit
  def edit
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)

    begin
      ActiveRecord::Base.transaction do
        # 両方の Validation を実行しておく
        campaign_invalid = @campaign.invalid?

        if campaign_invalid
          render :new
          return
        end

        @campaign.save!

        # 対応するオファーを作成
        @campaign.update_related_offers

        redirect_to :action => 'index', notice: 'Campaign was successfully created.'
      end
    rescue => e
      logger.error e
      render :new
    end
  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    # TODO: ここらへん見るものが多岐にわたるからキャンペーン単位でロックかけておく方が安全か？
    # TODO: 本当に楽観的ロックで大丈夫か？
    begin
      ActiveRecord::Base.transaction do
        # 両方の Validation を実行しておく
        #campaign = Campaign.new(campaign_params)
        #campaign_invalid = campaign.invalid?
        campaign_invalid = false

        if campaign_invalid
          @campaign.attributes = campaign_params
          @campaign.valid?  # エラーメッセージを入れるため

          render :edit
          return
        end

        @campaign.update!(campaign_params)

        # 対応するオファー更新
        @campaign.update_related_offers

        redirect_to :action => 'index', notice: 'Campaign was successfully created.'
      end
    rescue => e
      @campaign.errors[:base] << e.message
      logger.error e.message
      render :edit
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.json
  def destroy
    @campaign.destroy
    respond_to do |format|
      format.html { redirect_to campaigns_url, notice: 'Campaign was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = Campaign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def campaign_params
      # 多対多関連のチェックボックスに対応
      # http://qiita.com/gotohiro55/items/0d76ac9412b04a431e32
      p = params.require(:campaign).permit(:campaign_source_id, :source_campaign_identifier, :network_id, :campaign_category_id, :name, :detail, :icon_url, :url, :requirement, :requirement_detail, :period, :price, :payment, :payment_is_including_tax, :point, :available, :medium_ids => [])
      p[:medium_ids] ||= []
      p
    end
end
