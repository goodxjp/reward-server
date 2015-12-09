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
        #advertisement_invalid = @advertisement.invalid?

        #if campaign_invalid or advertisement_invalid
        if campaign_invalid
          render :new
          return
        end

        @campaign.save!
        #@advertisement.campaign_id = @campaign.id

        #@advertisement.save!

        # オファー作成
        if @campaign.available
          @campaign.media.each do |medium|
            #offer = Offer.new
            offer = Offer.create_from_campaign(medium, @campaign)
            offer.save!
          end
        end

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
    #advertisement_params = params.require(:campaign).require(:advertisement).permit(:price, :payment, :point)

    # TODO: ここらへん見るものが多岐にわたるからキャンペーン単位でロックかけておく方が安全か？
    # TODO: 本当に楽観的ロックで大丈夫か？
    begin
      ActiveRecord::Base.transaction do
        # 両方の Validation を実行しておく
        #campaign = Campaign.new(campaign_params)
        #campaign_invalid = campaign.invalid?
        campaign_invalid = false
        #advertisement = Advertisement.new(advertisement_params)
        #advertisement_invalid = advertisement.invalid?

        #if campaign_invalid or advertisement_invalid
        if campaign_invalid
          #@advertisement = @campaign.advertisements[0]

          @campaign.attributes = campaign_params
          @campaign.valid?  # エラーメッセージを入れるため
          #@advertisement.attributes = advertisement_params
          #@advertisement.valid?  # エラーメッセージを入れるため

          render :edit
          return
        end

        @campaign.update!(campaign_params)
        #@advertisement = @campaign.advertisements[0]
        #@advertisement.update!(advertisement_params)

        #
        # 差分をチェックしてオファー更新、新規作成
        #
        media = Medium.all  # 今はメディアが少ないので全メディアに対して処理を行う。将来的には差分のみ実施
        media.each do |medium|
          # チェック対象となるオファーを取得
          offers = Offer.where(:campaign => @campaign, :medium => medium)

          if @campaign.available and @campaign.media.include?(medium)
            #
            # 配信対象メディア
            #
            # すでにオファーがないかチェックしながら、有効、無効を切り替える
            offer_exists = false
            offers.each do |offer|
              if offer.equal?(@campaign)
                offer.available = true
                offer_exists = true
                # TODO: 万が一複数できたらどうするか？
              else
                offer.available = false
              end
              offer.save!  # TODO: 保存する必要がないものは保存しないようにしたい
            end

            # オファーがなければ新規作成
            if not offer_exists
              new_offer = Offer.create_from_campaign(medium, @campaign)
              new_offer.save!
            end
          else
            #
            # 配信停止メディア
            #
            offers.each do |offer|
              offer.available = false
              offer.save!  # TODO: 保存する必要がないものは保存しないようにしたい
            end
          end
        end

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
