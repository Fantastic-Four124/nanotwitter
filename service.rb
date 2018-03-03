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
    session[:username] ? session[:username] : 'Hello stranger'
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
    @user = session[:user_hash]
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

get '/search' do
  if protected!
    @texts = 'logined'
    erb :search
  else
    redirect '/login'
  end
end

get '/users/:user_id' do
  if protected!
    @user = User.find(params['user_id'])
    tweets = Tweet.where("user_id = '#{@user.id}'").sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..50]
    erb :tweet_feed
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

