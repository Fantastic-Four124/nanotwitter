require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'
require 'time_difference'
require_relative 'models/user'
require_relative 'models/hashtag'
require_relative 'models/mention'
require_relative 'models/tweet'
require_relative 'models/hashtag_tweets'

enable :sessions

set :bind, '0.0.0.0' # Needed to work with Vagrant

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

get '/login' do
  if protected!
    redirect '/'
  else
    erb :login
  end
end

post '/login' do
  user = User.find_by(username: params['username'], password: params['password'])
  if !user.nil?
    session[:username] = params['username']
    session[:password] = params['password']
    session[:user_id] = user.id
    session[:user_hash] = user
    redirect '/'
  else
    @texts = 'Wrong password or username.'
    erb :login
  end
end

# All other pages need to have these session objects checked.
get '/' do
  if protected!
    @curr_user = session[:user_hash]
    tweets = Tweet.where("user_id = '#{session[:user_id]}'").sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..50]
    erb :logged_root
  else
    tweets = Tweet.all.sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..50]
    erb :tweet_feed
  end
end
# All other pages should have "protected!" as the first thing that they do.
get '/user/register' do
  if protected!
    @texts = 'logined'
    redirect '/'
  else
    erb :register
  end
end

post '/user/register' do
  username = params[:register]['username']
	password = params[:register]['password']
  @user = User.new(username: username,password: password)
  if @user.save
    session[:user_id] = @user.id
    session[:username] = params['username']
    session[:password] = params['password']
    session[:user_hash] = @user
    redirect "/"
  else
    redirect '/user/register'
  end
end

get '/users/:user_id' do
  if protected!
    @curr_user = User.find(params['user_id'])
    tweets = Tweet.where("user_id = '#{@curr_user.id}'").sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..50]
    erb :tweet_feed
  else
    redirect '/'
  end
end

get '/user/:user_id/followers' do
  if protected!
    #TODO: implement followers/leaders; right now using user #2 as dummy
    @curr_user = User.find(params['user_id'])
    follower = User.find(2)
    @user_list = []
    @user_list << follower
    @title = 'Followers'
    erb :user_list
  else
    redirect '/'
  end
end


get '/user/:user_id/leaders' do
  if protected!
    #TODO: implement followers/leaders; right now using user #2 as dummy
    @curr_user = User.find(params['user_id'])
    follower = User.find(2)
    @user_list = []
    @user_list << follower
    @title = 'Leaders'
    erb :user_list
  else
    redirect '/'
  end
end

post '/logout' do
  session.delete(:username)
  session.delete(:password)
  session.delete(:user_id)
  session.delete(:user_hash)
  redirect '/'
end


get '/search' do
  @curr_user = session[:user_hash]
  term = params[:search]
  if term
    @no_term = false
    if /([@.])\w+/.match(term)
      term = term[1..-1]
      @results = User.where("username like ?", "%#{term}%")
      @user_search = true
    else
      @results = Tweet.where("message like ?", "%#{term}%").sort_by &:created_at
      @results.reverse!
      @user_search = false
    end
  else
    @no_term = true
    @results = []
  end
  erb :search_results
end

post '/tweets/new' do
  usr = session[:user_hash]
  msg = params[:tweet]['message']
  new_tweet = Tweet.new(user: usr, message: msg)
  if new_tweet.save
    redirect '/'
  else
    @error = 'Tweet could not be saved'
    redirect '/'
  end
end

