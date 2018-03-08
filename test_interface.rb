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

def recreate_testuser
  result = User.new(username: TESTUSER_NAME, password: TESTUSER_PASSWORD).save
  puts "Recreate testuser -> #{result}"
end

# Danger Zone! It will remove everthing in the DB
def clear_all()
  User.destroy_all
  Hashtag.destroy_all
  Mention.destroy_all
  Tweet.destroy_all
  # Hashtag_tweets.destroy_all
end

# What happen when you break up with someone.... ;(
def remove_everything_about(name)
  list_of_activerecords = [
    Follow.find_by(leader_id: name),
    Follow.find_by(user_id: name),
    Mention.find_by(username: name),
    Tweet.find_by(user_id: name),
    User.find_by(username: name)
  ]
  list_of_activerecords.each { |ar| destroy_and_save(ar) }
end

# Helper method, for active record object ONLY!
def destroy_and_save(active_record_object)
  active_record_object.destroy
  active_record_object.save
end

def report_status
  status = {
    'number of users': User.count,
    'number of tweets': Tweet.count,
    'number of follow': Follow.count,
    'Id of Test user': TESTUSER_NAME
  }
  status
end

post '/test/reset/all' do
  clear_all
  recreate_testuser
end

post '/test/reset/testuser' do
  remove_everything_about(TESTUSER_NAME)
  recreate_testuser
  puts report_status
end

# Report the current version
get '/test/version' do
  "Version: #{Version.VERSION}".to_json
end

# One page report
# How many users, follows, and tweets are there. What is the TestUser’s id
get '/test/status' do
  st = report_status
  st.to_json
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


