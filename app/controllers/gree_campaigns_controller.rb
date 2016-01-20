# -*- coding: utf-8 -*-
class GreeCampaignsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_gree_campaign, only: [:show, :destroy, :toggle_mute]

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
    @campaign = @gree_campaign.corresponding_campaign

    mute = Mute.find_by(target: @gree_campaign)
    if mute.nil?
      @is_mute = false
    else
      @is_mute = true
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

  def toggle_mute
    mute = Mute.find_by(target: @gree_campaign)

    if mute.nil?
      Mute.create(target: @gree_campaign)
    else
      mute.destroy
    end

    redirect_to action: :show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gree_campaign
      @gree_campaign = GreeCampaign.find(params[:id])
    end
end
