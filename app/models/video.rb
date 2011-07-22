class Video < ActiveRecord::Base
  has_attached_file :source
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
    return $1 if self.meta[:size] =~ /(\d*)x(\d*)/
  end
  def height
    return $2 if self.meta[:size] =~ /(\d*)x(\d*)/
  end
  
  def flvurl
    self.source.url.gsub(/\..*$/,'.flv')
  end
  
  def thumburl
    self.source.url.gsub(/\..*$/,'.jpg')
  end
end
