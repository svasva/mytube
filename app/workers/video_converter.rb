#include FFMpeg
class VideoConverter
  @queue = :VideoConversion
  @cmd360p = ''
  @ffmpeg = '/usr/bin/ffmpeg'
  @composite = '/usr/bin/composite'
  @playbutton = 'play.png'
  def self.perform()
    videos = Video.where :current_state => :pending
    videos.each do |video|
      video.source_meta = identify(video.source)
      convert360p(video)

    end
  end

  protected

  def self.convert360p(video)
    video.reset
    video.convert!
    fname = 'public'+video.source.url
    movie = FFMPEG::Movie.new(fname)
    options = {:resolution => '480x360', :audio_sample_rate => 22050, :custom => '-sameq' }
    transcoder_options = {:preserve_aspect_ratio => :width}
    movie.transcode(fname.gsub(/\..*$/,'.flv'), options, transcoder_options) ? video.converted! : video.failed!
    makethumbnail(video)
    video.save
  end

  def self.convert480p(file)
  end

  def self.convert720p(file)
  end

  def self.makethumbnail(video)
    thumb = "public#{video.source.url.gsub(/\..*$/, '.jpg')}"
    pad = "\"320:180:(iw-ow)/2:(ih-oh)/2\""
    system("#{@ffmpeg} -ss 2 -i public#{video.flvurl} -r 1 -f mjpeg -aspect #{video.source_meta[:aspect]} -s 320x180 -vframes 1 #{thumb}")
    #system("#{@composite} -gravity center #{@playbutton} #{thumb} #{thumb}")
  end

  def self.identify(file)
    meta = {}
    command = "ffmpeg -i #{File.expand_path(file.path)} 2>&1"
    ffmpeg = IO.popen(command)
    ffmpeg.each("\r") do |line|
      if line =~ /((\d*)\s.?)fps,/
        meta[:fps] = $1.to_i
      end
      # Matching lines like:
      # Video: h264, yuvj420p, 640x480 [PAR 72:72 DAR 4:3], 10301 kb/s, 30 fps, 30 tbr, 600 tbn, 600 tbc
      if line =~ /Video:(.*)/
        v = $1.to_s.split(',')
        size = v[2].strip!.split(' ').first
        meta[:size] = size.to_s
        meta[:aspect] = size.split('x').first.to_f / size.split('x').last.to_f
      end
      # Matching Duration: 00:01:31.66, start: 0.000000, bitrate: 10404 kb/s
      if line =~ /Duration:(\s.?(\d*):(\d*):(\d*\.\d*))/
        meta[:length] = $2.to_s + ":" + $3.to_s + ":" + $4.to_s
      end
    end
    meta
  end
end
