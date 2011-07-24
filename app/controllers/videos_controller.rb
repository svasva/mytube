require 'fileutils'

class VideosController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :my]
  def index
    @videos = Video.find(:all)
  end

  def my
    @videos = current_user.videos
  end

  def new
    redirect_to :back unless params[:filename]
    @video = Video.new
    #@filename = params[:filename]
  end

  def create
    @video = Video.new(params[:video])
    @video.author = current_user
    @video.source = File.new(@video.source_file_name)
    if @video.save
      FileUtils.rm(@video.source_file_name)
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
    thumb = "public/tmp/uploads/#{name.gsub(/\..*$/, '.jpg')}"
    pad = "\"320:180:(iw-ow)/2:(ih-oh)/2\""
    system("ffmpeg -ss 2 -i #{dir}/#{name} -r 1 -f mjpeg -vf pad=#{pad} -s 320x180 -vframes 1 #{thumb}")
    render :text => "#{dir}/#{name}"
  end
end
