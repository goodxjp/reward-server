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
    # 対応する GREE キャンペーン
    # TODO: 汎用的に
    if @campaign.campaign_source_id == 2
      gree_campaigns = GreeCampaign.where(campaign_source: @campaign.campaign_source, campaign_identifier: @campaign.source_campaign_identifier)
      if gree_campaigns.size > 1
        logger_fatal "GreeCampaigns is incorrect. (campaign_identifier = #{@campaign.source_campaign_identifier})"
        @source = gree_campaigns[0]
      elsif gree_campaigns.size == 1
        @source = gree_campaigns[0]
      else
        @source = nil
      end
    end
  end

  # GET /campaigns/new
  def new
    if not params[:gree_campaign_id].nil?
      gree_campaign = GreeCampaign.find(params[:gree_campaign_id])
      @campaign = Campaign.new
      # TODO: ここらへんの変換ルールをモデルに
      @campaign.network_id = 3  # TODO: ここら辺もう定数だな。どうにかしたい。
      @campaign.campaign_source_id = 2  # TODO: ここら辺もう定数だな。どうにかしたい。
      @campaign.source_campaign_identifier = gree_campaign.campaign_identifier

      @campaign.name = gree_campaign.site_name
      @campaign.detail = gree_campaign.site_description
      @campaign.icon_url = gree_campaign.icon_url
      @campaign.url = gree_campaign.get_url_for_campaign
      @campaign.requirement = gree_campaign.default_thanks_name
      @campaign.requirement_detail = gree_campaign.draft

      # TODO
      @campaign.period = "10 分程度"
      @campaign.price = gree_campaign.site_price
      @campaign.payment = gree_campaign.thanks_media_revenue
      @campaign.payment_is_including_tax = true
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
