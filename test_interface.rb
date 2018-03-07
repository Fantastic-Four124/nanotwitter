require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'
require_relative 'models/user'
require_relative 'models/hashtag'
require_relative 'models/mention'
require_relative 'models/tweet'
require_relative 'models/hashtag_tweets'
require_relative './version'

# name: testuser
# email: testuser@sample.com
# password: “password”

TESTUSER_NAME = 'testuser'
TESTUSER_EMAIL = 'testuser@sample.com'
TESTUSER_PASSWORD = 'password'

helpers do

  def recreate_TestUser()
    result = User.new(username: TESTUSER_NAME, password: TESTUSER_PASSWORD).save
    puts "Recreate testuser -> #{result}"
    
  end

  def clear_all()
    User.destroy_all
    Hashtag.destroy_all
    Mention.destroy_all
    Tweet.destroy_all
    # Hashtag_tweets.destroy_all
  end
end

post '/test/reset/all' do
  clear_all
  recreate_TestUser
end


post '/test/reset/testuser' do

  # TODO: DO SOMETHING
  recreate_TestUser
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
      if num <= 0
        raise ArgumentError, 'Argument is smaller than zero'
      end
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

# user u generates t(integer) new fake tweets
post '/test/user/:user/tweets?' do
  puts params
  input_user = params[:user] # who
  input_count = params[:count]
  begin
    count = Integer(input_count) # number of fake tweets needed to generate
    # TODO: DO SOMETHING
    # TODO: DO SOMETHING
    # TODO: DO SOMETHING
    'TODO'.to_json
  rescue
    # Wrong input
    "Nah, input is not valid, \nparams = #{params}".to_json
  end
  
end


