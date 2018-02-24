require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'

set :bind, '0.0.0.0' # Needed to work with Vagrant

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    redirect '/login', 'Incorrect username or password'
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    # In addition to the checks below, does a call to the user database with the given username and password even exist?
    @auth.provided? and @auth.basic? and @auth.credentials and User.exist?(name: @auth.credentials[0], password: @auth.credentials[1])
  end
end

get '/login' do
  erb :login
end

post '/login' do

end

# All other pages should have "protected!" as the first thing that they do.
get '/' do
  protected!
end
