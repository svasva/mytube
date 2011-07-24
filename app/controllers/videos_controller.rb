class VideosController < ApplicationController
  before_filter :authenticate_user!, :only => :new
  def index
    (params[:my]) ? @videos = current_user.videos : @videos = Video.find(:all)
  end

  def new
    @video = Video.new
    unless params[:filename]
      redirect_to :back
      return
    end
    @video.source = File.new(params[:filename])
    redirect_to :back unless @video.source
  end

  def create
    @video = Video.new(params[:video])
    @video.author = current_user
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
    Video.find(params[:id]).destroy
    redirect_to videos_path
  end

  def upload
    extension = File.extname(params[:Filedata].original_filename).downcase
    name = "#{SecureRandom.hex(16)}#{extension}"
    dir = "tmp/uploads"
    path = File.join(dir,name)
    File.open(path, "wb") {|f| f.write(params[:Filedata].read) }
    render :text => "#{dir}/#{name}"
  end
end
