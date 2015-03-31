# -*- coding: cp932 -*-
class MediaUsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [ :create ]

  def index
    @media_users = MediaUser.all
  end

  def create
    @media_user = MediaUser.new(media_user_params)

    if @media_user.save
      render json: @media_user
      return
    end
  end

  def destroy
    @media_user = MediaUser.find(params[:id])
    @media_user.destroy
    head :no_content
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
    def media_user_params
      params.require(:media_user).permit(:terminal_id, :terminal_info, :android_registration_id)
    end
end
