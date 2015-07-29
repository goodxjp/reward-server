# -*- coding: utf-8 -*-
class NetworkSystemsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_network_system, only: [:show]

  # GET /network_systems
  def index
    @network_systems = NetworkSystem.all
  end

  # GET /network_systems/1
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_network_system
      @network_system = NetworkSystem.find(params[:id])
    end
end
