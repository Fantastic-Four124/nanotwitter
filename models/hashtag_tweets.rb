class HashtagTweets < ActiveRecord::Base
  validates :hashtag_id,presence:true
  validates :tweet_id,presence:true
  belongs_to :hashtags
  belongs_to :tweets
end
