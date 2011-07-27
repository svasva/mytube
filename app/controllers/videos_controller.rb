require 'fileutils'
class VideosController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :upload]
  def index
    @videos = Video.find(:all)
  end

  def my
    @videos = current_user.videos
    render :template => 'videos/index'
  end

  def new
    redirect_to :action => :index unless params[:filename]
    @video = Video.new
  end

  def create
    @video = Video.new(params[:video])
    @video.author = current_user
    file = @video.source_file_name
    @video.source = File.new(file)
    if @video.save
      #FileUtils.rm(file)
      @video.convert
      flash[:notice] = 'Video has been uploaded'
      redirect_to :action => :my
    end
  end

  def show
    @video = Video.find(params[:id], :include => { :comments => [{:replies => :author}, :author] })
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
    logger.info "/usr/bin/ffmpeg -ss 2 -i #{dir}/#{name} -r 1 -f mjpeg -s 320x180 -vframes 1 #{thumb} 2>&1 >> tmp/ff.log"
    puts "/usr/bin/ffmpeg -ss 2 -i #{dir}/#{name} -r 1 -f mjpeg -s 320x180 -vframes 1 #{thumb} 2>&1 >> tmp/ff.log"
    system("/usr/bin/ffmpeg -ss 2 -i #{dir}/#{name} -r 1 -f mjpeg -s 320x180 -vframes 1 #{thumb} 2>&1 >> tmp/ff.log")
    render :text => "#{dir}/#{name}"
  end
end
