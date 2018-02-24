class User < ActiveRecord::Base
  validates :last_name,presence:true
  validates :first_name,presence:true
  validates :email,presence:true
  validates :password,presence:true
  validates :digest,presence:true
  validates_uniqueness_of :username
  has_many :users, through: :follows
  has_many :tweets
  has_many :tweets, through: :mentions

end
