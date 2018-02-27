class Tweet < ActiveRecord::Base
  validates :message,presence:true
  validates :timestamp,presence:true
  belongs_to :users
  has_many :users, through: :mentions
  has_many :hashtags,through: :hashtag_tweets


end
