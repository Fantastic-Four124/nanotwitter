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


post '/test/reset/testuser' do
  # TODO: DO SOMETHING
  # TODO: DO SOMETHING
  # TODO: DO SOMETHING
  puts params
end

# Report the current version
get '/test/version' do
  "Version: #{Version.VERSION}".to_json
end

# One page report
# How many users, follows, and tweets are there. What is the TestUser’s id
get '/test/status' do
  # TODO: DO SOMETHING
  # TODO: DO SOMETHING
  # TODO: DO SOMETHING
  puts params
  'STATUS'.to_json
end

# Read from seed
# correct format should be /test/reset/standard?tweets=6
post '/test/reset/standard?' do
  puts params
  input = params[:tweets]
  begin
    if params.length == 1
      num = -1 # -1 means no limit
    else
      num = Integer(input) # only load n tweets from seed data
    end
    # TODO: DO SOMETHING
    # TODO: DO SOMETHING
    # TODO: DO SOMETHING
    "GOOD: #{num}".to_json
  rescue
    # Wrong input
    "Nah, input is not valid, \nparams = #{params}".to_json
  end
end

# create u (integer) fake Users using faker. Defaults to 1.
# each of those users gets c (integer) fake tweets. Defaults to zero.
# Example: /test/users/create?count=100&tweets=5
post '/test/users/create?' do
  input_count = params[:count]
  input_tweet = params[:tweets]
  begin
    count = Integer(input_count)
    tweet = Integer(input_tweet)
    # TODO: DO SOMETHING
    # TODO: DO SOMETHING
    # TODO: DO SOMETHING
    "GOOD:\n\tcount: #{count}, tweet: #{tweet}".to_json
  rescue
    # Wrong input
    "Nah, input is not valid, \nparams = #{params}".to_json
  end
end

# ??? User u is a number?
post '/test/user' do
  puts params
  'TODO'.to_json
end


