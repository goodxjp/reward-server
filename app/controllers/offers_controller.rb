# -*- coding: utf-8 -*-
class OffersController < ApplicationController
  before_action :set_offer, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @offers = Offer.all

    # TODO: メディアの特定
    medium = Medium.first

    # TODO: ユーザーの特定

    # TODO: API は明確に処理を別けた方がよさげ

    # Devise のせいで Scaffold の生成コードが変わった。
    #respond_with(@offers)
    respond_to do |format|
      format.html
      format.json { @offers = Offer.where(:available => true, :medium => medium) }
    end
  end

  def show
    respond_with(@offer)
  end

  def new
    @offer = Offer.new
    respond_with(@offer)
  end

  def edit
  end

  def create
    @offer = Offer.new(offer_params)
    @offer.save
    respond_with(@offer)
  end

  def update
    @offer.update(offer_params)
    respond_with(@offer)
  end

  def destroy
    @offer.destroy
    respond_with(@offer)
  end

  private
    def set_offer
      @offer = Offer.find(params[:id])
    end

    def offer_params
      params.require(:offer).permit(:campaign, :medium, :campaign_category, :name, :detail, :icon_url, :url, :requirement, :requirement_detail, :period, :price, :payment, :point)
    end
end
