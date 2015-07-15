# -*- coding: utf-8 -*-
class AchievementsController < ApplicationController
  before_action :authenticate_admin_user!

  def index
    @achievements = Achievement.order(id: :desc).page params[:page]
  end
end
