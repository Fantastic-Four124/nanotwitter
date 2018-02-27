class User < ActiveRecord::Base
  validates :last_name,presence:true
  validates :first_name,presence:true
  validates :email,presence:true
  validates :password_digest,presence:true
  validates :digest,presence:true
  validates_uniqueness_of :username
  has_many :users, through: :follows
  has_many :followings, :class_name => "Follow",:foreign_key => :followed_user_id
  has_many :followers, :through => :followings,:source => :user
  has_many :tweets
  has_many :tweets, through: :mentions

end
