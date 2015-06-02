# -*- coding: utf-8 -*-
class GiftsController < ApplicationController
  before_action :authenticate_admin_user!

  # Item の入れ子
  def create
    @item = Item.find(params[:item_id])
    @gift = Gift.new(gift_params)
    @gift.item = @item

    if @gift.save
      redirect_to @item
    else
      # item/show と同じにする
      @gifts = @item.gifts.order(id: :desc).page params[:page]
      @form = GiftNewForm.new
      # TODO: validation エラーをきちんと表示したい。
      render 'items/show'
    end
  end

  private
    def gift_params
      params.require(:gift).permit(:code, :expiration_at)
    end
end
