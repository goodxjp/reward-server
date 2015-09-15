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
    if @medium.save
      #respond_with(@medium)
      redirect_to :action => 'index', notice: 'Campaign was successfully created.'
    else
      render :new
    end
  end

  def update
    if @medium.update(medium_params)
      #respond_with(@medium)
      redirect_to :action => 'index', notice: 'Campaign was successfully created.'
    else
      render :edit
    end
  end

  def destroy
    @medium.destroy
    #respond_with(@medium)
    redirect_to :action => 'index', notice: 'Campaign was successfully created.'
  end

  private
    def set_medium
      @medium = Medium.find(params[:id])
    end

    def medium_params
      params.require(:medium).permit(:name, :key, :media_type_id, :at_least_app_version_code)
    end
end
