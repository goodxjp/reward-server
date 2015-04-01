# -*- coding: utf-8 -*-
class MediaUsersController < ApplicationController
  before_action :set_media_user, only: [:show, :edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => [ :create ]

  def index
    @media_users = MediaUser.all
  end

  def show
  end

  def create
    @media_user = MediaUser.new(media_user_params)

    if @media_user.save
      render json: @media_user
      return
    end
  end

  def destroy
    @media_user.destroy
    redirect_to media_users_url, notice: 'MediaUser was successfully destroyed.'
  end

  def notify
    @media_user = MediaUser.find(params[:id])
    api_key = ENV['API_KEY']
    registration_ids = [ @media_user.android_registration_id ]
    gcm = GCM.new(api_key)
    options = { data: { message: "通知のテスト" }, collapse_key: "test" }
    response = gcm.send_notification(registration_ids, options)

    head :no_content
  end

  private
    def set_media_user
      @media_user = MediaUser.find(params[:id])
    end

    def media_user_params
      params.require(:media_user).permit(:terminal_id, :terminal_info, :android_registration_id)
    end
end
