require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'

set :bind, '0.0.0.0' # Needed to work with Vagrant

configure do
  set :twitter_client, false
end

helpers do
  def protected!
    return settings.twitter_client # for testing only
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    redirect '/login', 'Incorrect username or password'
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    # In addition to the checks below, does a call to the user database with the given username and password even exist?
    # @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == #Insert existing username and password combination
  end
end

get '/login' do
  erb :login
end

post '/login' do
  username = params['username']
  password = params['password']
  if username == '105' && password == 'pw'
    settings.twitter_client = true
    redirect '/'
  else
    @texts = 'Wrong password or username.'
    erb :login
  end
end

# All other pages should have "protected!" as the first thing that they do.
get '/' do
  if protected!
    @texts = 'logined'
    erb :home
  else
    erb :login
  end
end
# All other pages should have "protected!" as the first thing that they do.
