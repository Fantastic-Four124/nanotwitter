require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'

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
  erb :login
end

post '/login' do
  if params['username'] == '105' && params['password'] == 'pw' # User.exist?(username: session[:username], password: session[:password])
    session[:username] = params['username']
    session[:password] = params['password']
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
    erb :home
  else
    erb :register
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
