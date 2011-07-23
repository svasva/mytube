require 'FileUtils'

class VideosController < ApplicationController
  before_filter :authenticate_user!, :only => :new
  def index
    @videos = Video.find :all
  end

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(params[:video])
    if @video.save
      @video.convert
      flash[:notice] = 'Video has been uploaded'
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def show
    @video = Video.find(params[:id])
  end

  def update
  end

  def destroy
    FileUtils.rm_rf "public/system/sources/#{params[:id]}"
    Video.find(params[:id]).destroy
    redirect_to videos_path
  end
end
