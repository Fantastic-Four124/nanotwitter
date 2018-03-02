require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'
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
end

get '/login' do
  #byebug
  #erb :login
  if protected!
    @texts = 'logged in'
    erb :home
  else
    erb :login
  end
end

post '/login' do
  user = User.find_by(username: params['username'], password: params['password'])
  if params['username'] == '105' && params['password'] == 'pw' # User.exist?(username: session[:username], password: session[:password])
    session[:username] = params['username']
    session[:password] = params['password']
    redirect '/'
  elsif !user.nil?
    session[:username] = params['username']
    session[:password] = params['password']
    session[:user_id] = user.id
    redirect '/'
  else
    @texts = 'Wrong password or username.'
    erb :login
  end
end

# All other pages need to have these session objects checked.
get '/' do
  #byebug
  if protected!
    @texts = 'logged in'
    erb :home
  else
    erb :login
  end
end
# All other pages should have "protected!" as the first thing that they do.
get '/user/register' do
  if protected!
    @texts = 'logged in'
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
    redirect "/"
  else
    redirect '/user/register'
  end
end

get '/search' do
  if protected!
    @texts = 'logged in'
    erb :search
  else
    redirect '/login'
  end
end


post '/logout' do
  session.delete(:username)
  session.delete(:password)
  redirect '/'
end
