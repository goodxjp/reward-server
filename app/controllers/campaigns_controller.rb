# -*- coding: utf-8 -*-
class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]

  # GET /campaigns
  # GET /campaigns.json
  def index
    @campaigns = Campaign.order(id: :desc)
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
    @advertisement = Advertisement.new
  end

  # GET /campaigns/1/edit
  def edit
    @advertisement = @campaign.advertisements[0]
  end

  # POST /campaigns
  # POST /campaigns.json
  def create
    @campaign = Campaign.new(campaign_params)
    @advertisement = Advertisement.new(params.require(:campaign).require(:advertisement).permit(:price, :payment, :point))

    begin
      ActiveRecord::Base.transaction do
        # 両方の Validation を実行しておく
        campaign_invalid = @campaign.invalid?
        advertisement_invalid = @advertisement.invalid?

        if campaign_invalid or advertisement_invalid
          render :new
          return
        end

        @campaign.save!
        @advertisement.campaign_id = @campaign.id

        @advertisement.save!

        # オファー作成
        @campaign.media.each do |medium|
          #offer = Offer.new
          offer = Offer.create_from_campaign(medium, @campaign)
          offer.save!
        end

        redirect_to :action => 'index', notice: 'Campaign was successfully created.'
      end
    rescue => e
      logger.debug e
      render :new
    end
  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    advertisement_params = params.require(:campaign).require(:advertisement).permit(:price, :payment, :point)

    # TODO: ここらへん見るものが多岐にわたるからキャンペーン単位でロックかけておく方が安全か？
    # TODO: 本当に楽観的ロックで大丈夫か？
    begin
      ActiveRecord::Base.transaction do
        # 両方の Validation を実行しておく
        campaign = Campaign.new(campaign_params)
        campaign_invalid = campaign.invalid?
        advertisement = Advertisement.new(advertisement_params)
        advertisement_invalid = advertisement.invalid?

        if campaign_invalid or advertisement_invalid
          @advertisement = @campaign.advertisements[0]

          @campaign.attributes = campaign_params
          @campaign.valid?  # エラーメッセージを入れるため
          @advertisement.attributes = advertisement_params
          @advertisement.valid?  # エラーメッセージを入れるため

          render :edit
          return
        end

        @campaign.update!(campaign_params)
        @advertisement = @campaign.advertisements[0]
        @advertisement.update!(advertisement_params)

        #
        # 差分をチェックしてオファー更新、新規作成
        #
        media = Medium.all  # 今はメディアが少ないので全メディアに対して処理を行う。将来的には差分のみ実施
        media.each do |medium|
          # チェック対象となるオファーを取得
          offers = Offer.where(:campaign => @campaign, :medium => medium)

          if @campaign.media.include?(medium)
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
      logger.debug e
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

  # 案件実行
  def execute
    @campaign = Campaign.find(params[:id])

    # TODO: ユーザー ID と署名のチェック

    # TODO: クリック履歴の記録

    redirect_to @campaign.url
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
      p = params.require(:campaign).permit(:network_id, :campaign_category_id, :name, :detail, :icon_url, :url, :requirement, :requirement_detail, :period, :medium_ids => [])
      p[:medium_ids] ||= []
      p
    end
end
