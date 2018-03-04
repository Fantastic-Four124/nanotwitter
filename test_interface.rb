require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'
require_relative 'models/user'
require_relative 'models/hashtag'
require_relative 'models/mention'
require_relative 'models/tweet'
require_relative 'models/hashtag_tweets'
require_relative './version'

post '/test/reset/all' do
  User.destroy_all
  Hashtag.destroy_all
  Mention.destroy_all
  Tweet.destroy_all
  Hashtag_tweets.destroy_all
end


post "/test/reset/testuser" do
  
end

get '/test/version' do
  Version.VERSION.to_json
end

get '/test/status' do 

end

post '/test/reset/standard?tweets=' do 

end