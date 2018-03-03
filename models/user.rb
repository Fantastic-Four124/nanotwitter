class User < ActiveRecord::Base
  validates :username,presence:true
  validates :password,presence:true
  validates_uniqueness_of :username
  has_many :users, through: :follows
  has_many :followings, :class_name => "Follow",:foreign_key => :followed_user_id
  has_many :followers, :through => :followings,:source => :user
  has_many :tweets
  has_many :tweets, through: :mentions
end
