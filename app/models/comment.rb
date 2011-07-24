class Comment < ActiveRecord::Base
  belongs_to :video
  belongs_to :author, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :parent, :class_name => 'Comment'
  has_many :replies,  :class_name => 'Comment', :foreign_key => 'parent_id'
end
