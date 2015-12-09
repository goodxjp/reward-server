# -*- coding: utf-8 -*-
class GreeCampaignsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_gree_campaign, only: [:show, :destroy]

  # GET /campaigns
  # GET /campaigns.json
  def index
    @q = GreeCampaign.search(params[:q])
    @gree_campaigns = @q.result.order(id: :desc).page params[:page]
  end

  # GET /campaigns/1
  # GET /campaigns/1.json
  def show
    # 対応するキャンペーン
    campaigns = Campaign.where(campaign_source: @gree_campaign.campaign_source, source_campaign_identifier: @gree_campaign.campaign_identifier)
    if campaigns.size > 1
      logger_fatal "Campaigns are duplication. (campaign_source = #{@gree_campaign.campaign_source}, source_campaign_identifier =  #{@gree_campaign.campaign_identifier} )"
      @campaign = campaigns[0]
      # TODO: 警告出したい
    elsif campaigns.size == 1
      @campaign = campaigns[0]
    else
      @campaign = nil
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
    def set_gree_campaign
      @gree_campaign = GreeCampaign.find(params[:id])
    end
end
