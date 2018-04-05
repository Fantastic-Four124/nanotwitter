require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'
require_relative 'test_interface.rb'
require 'time_difference'
require 'time'
require 'json'
require 'rest-client'
require 'redis'
require_relative 'prefix.rb'
require_relative 'erb_constants.rb'
require_relative 'models/follow'
require_relative 'models/user'
require_relative 'models/hashtag'
require_relative 'models/mention'
require_relative 'models/tweet'
require_relative 'models/hashtag_tweets'

configure do
    uri = URI.parse("redis://rediscloud:5lKsZnGwfn5y9O12JAQ7T8vIWAKrr0P8@redis-16859.c14.us-east-1-3.ec2.cloud.redislabs.com:16859")
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    #byebug
end

Dir[File.dirname(__FILE__) + '/api/v1/user/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/api/v1/hashtag/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/api/v1/follow/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/api/v1/search/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/api/v1/tweet/*.rb'].each { |file| require file }

enable :sessions

set :bind, '0.0.0.0' # Needed to work with Vagrant

configure :production do
  require 'newrelic_rpm'
end

# configure do
#   set :twitter_client, false
# end

# Small helper that minimizes code
helpers do
  def protected!
    #return settings.twitter_client # for testing only
    return !session[:username].nil?
  end

  def identity
    session[:username] ? session[:username] : 'Log in'
  end
end

# For loader.io to auth
get '/loaderio-1541f51ead65ae3319ad8207fee20f8d.txt' do
  send_file 'loaderio-1541f51ead65ae3319ad8207fee20f8d.txt'
end

get '/' do
  redirect PREFIX + '/'
end

get PREFIX + '/login' do
  if protected!
    byebug
    @user_id = session[:user_id]
    redirect PREFIX + '/'
  else
    erb :login
  end
end

post PREFIX + '/login' do
  @user = User.find_by_username(params['username'])
  if !@user.nil? && @user.password == params['password']
    session[:username] = params['username']
    session[:password] = params['password']
    session[:user_id] = @user.id
    session[:user_hash] = @user
    redirect PREFIX + '/'
  else
    @texts = 'Wrong password or username.'
    erb :login
  end
end

# All other pages need to have these session objects checked.
get PREFIX + '/' do
  #byebug
  if protected!
    @curr_user = User.find(session[:user_id])
    leader_list = @curr_user.leaders
    tweets = []
    leader_list.each do |leader|
      # subtweets = JSON.parse(RestClient.get 'http://192.168.33.10:8090/api/v1/tweets/:username', {params: {name: leader.username}})
      subtweets = JSON.parse(RestClient.get 'https://nt-tweet-reader.herokuapp.com/api/v1/tweets/:username', {params: {name: leader.username}})
      tweets.push(*subtweets)
    end
    tweets.sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..49]
    erb :logged_root
  else
    # tweets = Tweet.all.sort_by &:created_at
    # tweets.reverse!
    # @tweets = JSON.parse(RestClient.get 'http://192.168.33.10:8090/api/v1/tweets/recent', {})
    @tweets = JSON.parse(RestClient.get 'https://nt-tweet-reader.herokuapp.com/api/v1/tweets/recent', {})
    erb :tweet_feed
  end
end
# All other pages should have "protected!" as the first thing that they do.
get PREFIX + '/user/register' do
  if protected!
    @texts = 'logined'
    redirect PREFIX + '/'
  else
    erb :register
  end
end

post PREFIX + '/user/register' do
  username = params[:register]['username']
	password = params[:register]['password']
  @user = User.new(username: username)
  @user.password = password
  @user.number_of_followers = 0
  @user.number_of_leaders = 0
  if @user.save
    session[:user_id] = @user.id
    session[:username] = params['username']
    session[:password] = params['password']
    session[:user_hash] = @user
    redirect PREFIX + "/"
  else
    redirect PREFIX + '/user/register'
  end
end

post PREFIX + '/logout' do
  session.delete(:username)
  session.delete(:password)
  session.delete(:user_id)
  session.delete(:user_hash)
  redirect PREFIX + '/'
end

get PREFIX + '/user/:user_id' do
  if protected!
    @curr_user = User.find(params['user_id'])
    # @tweets = JSON.parse(RestClient.get 'http://192.168.33.10:8090/api/v1/tweets/:username', {params: {name: session[:username]}})
    @tweets = JSON.parse(RestClient.get 'https://nt-tweet-reader.herokuapp.com/api/v1/tweets/:username', {params: {name: session[:username]}})
    #byebug
    #tweets = Tweet.where("user_id = '#{@curr_user.id}'").sort_by &:created_at
    #tweets.reverse!
    #@tweets = tweets[0..49]
    erb :tweet_feed
  else
    redirect PREFIX + '/'
  end
end
