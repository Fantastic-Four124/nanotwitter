class Mention < ActiveRecord::Base
  validates :username,presence:true
  validates :tweet_id,presence:true
  belongs_to :users
  belongs_to :tweets

end
