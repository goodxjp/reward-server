class CampaignsController < ApplicationController
  before_action :set_campaign, only: [:show, :edit, :update, :destroy]

  # GET /campaigns
  # GET /campaigns.json
  def index
    @campaigns = Campaign.all
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

    respond_to do |format|
      if not @campaign.save
        format.html { render :new }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
        return
      end

      @advertisement.campaign_id = @campaign.id
      if not @advertisement.save
        format.html { render :new }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
        return
      end

      format.html { redirect_to :action => 'index', notice: 'Campaign was successfully created.' }
      format.json { render :show, status: :created, location: @campaign }
    end
  end

  # PATCH/PUT /campaigns/1
  # PATCH/PUT /campaigns/1.json
  def update
    respond_to do |format|
      if @campaign.update(campaign_params)
        format.html { redirect_to :action => 'index', notice: 'Campaign was successfully updated.' }
        format.json { render :show, status: :ok, location: @campaign }
      else
        format.html { render :edit }
        format.json { render json: @campaign.errors, status: :unprocessable_entity }
      end
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
      params.require(:campaign).permit(:network_id, :name, :detail, :icon_url)
    end
end
