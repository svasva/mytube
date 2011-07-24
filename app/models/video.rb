class Video < ActiveRecord::Base
  require 'fileutils'
  belongs_to :author, :class_name => 'User', :foreign_key => 'user_id'
  has_many :comments
  has_attached_file :source
  before_create :randomize_file_name
  before_destroy :delete_files
  # Paperclip Validations
  validates_attachment_presence :source
  #validates_attachment_content_type :source, :content_type => 'video/quicktime'

  include AASM
  aasm_column :current_state
  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :converting
  aasm_state :converted
  aasm_state :error

  aasm_event :convert do
    transitions :from => :pending, :to => :converting
  end

  aasm_event :converted do
    transitions :from => :converting, :to => :converted
  end

  aasm_event :failed do
    transitions :from => :converting, :to => :error
  end

  def reset
    self.aasm_enter_initial_state
    self.save
  end

  def convert
    Resque.enqueue(VideoConverter)
  end

  def meta
    YAML::load(self.source_meta)
  end

  def width
    return $1.to_i if self.meta[:size] =~ /(\d*)x(\d*)/
  end
  def height
    return $2.to_i if self.meta[:size] =~ /(\d*)x(\d*)/
  end

  def flvurl
    self.source.url.gsub(/\..*$/,'.flv')
  end

  def thumburl
    self.source.url.gsub(/\..*$/,'.jpg')
  end

  private
    def delete_files
      FileUtils.rm_rf "public/system/sources/#{self.id}"
    end
    def randomize_file_name
      extension = File.extname(source_file_name).downcase
      self.source.instance_write(:file_name, "#{ActiveSupport::SecureRandom.hex(16)}#{extension}")
    end
end
