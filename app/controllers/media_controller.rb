class MediaController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :set_medium, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @media = Medium.order(:id)
    respond_with(@media)
  end

  def show
    respond_with(@medium)
  end

  def new
    @medium = Medium.new
    respond_with(@medium)
  end

  def edit
  end

  def create
    @medium = Medium.new(medium_params)
    @medium.save
    respond_with(@medium)
  end

  def update
    @medium.update(medium_params)
    respond_with(@medium)
  end

  def destroy
    @medium.destroy
    respond_with(@medium)
  end

  private
    def set_medium
      @medium = Medium.find(params[:id])
    end

    def medium_params
      params.require(:medium).permit(:name)
    end
end
