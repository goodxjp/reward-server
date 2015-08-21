# -*- coding: utf-8 -*-
class ItemsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_item, only: [:show, :edit, :update, :destroy, :register_codes]

  respond_to :html

  def index
    @items = Item.all.order(:id)
    respond_with(@items)
  end

  def show
    @gifts = @item.gifts.order(id: :desc).page params[:page]
    @form = GiftNewForm.new

    # ギフト券登録用
    @gift = Gift.new

    respond_with(@item)
  end

  def new
    @item = Item.new
    respond_with(@item)
  end

  def edit
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to action: :index
    else
      render :new
    end
  end

  def update
    if @item.update(item_params)
      redirect_to action: :index
    else
      render :edit
    end
  end

  def destroy
    @item.destroy
    respond_with(@item)
  end

  # ギフト券コード登録
  def register_codes
    @form = GiftNewForm.new(params[:gift_new_form])
    codes = @form.codes

    # ギフト券複数登録
    codes.each_line do |code|
      code.strip!
      if not code.empty?
        gift = Gift.new(item: @item, code: code, expiration_at: nil)
        gift.save
      end
    end

    redirect_to @item
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:name, :point, :available)
    end
end
