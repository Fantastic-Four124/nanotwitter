require 'minitest/autorun'
require 'rack/test'
require 'rake/testtask'
require_relative '../service.rb'
require_relative '../erb_constants.rb'
require_relative '../prefix.rb'

# These tests are not done yet! They still need to be filled out as we think of new functionality.

class ServiceTest < Minitest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    User.create(username: 'jim', password: 'abc', email: 'bob@bob.com')
  end

  def test_home
    get PREFIX + '/'
    assert last_response.ok? && (last_response.body.include? 'Login to nanoTwitter')
  end

  def test_login_page
    get PREFIX + '/login'
    assert last_response.ok? && (last_response.body.include? 'Login to Nanotwitter') && (last_response.body.include? `<form action="#{PREFIX}/login" method="POST">`)
  end

  def test_registration_page
    get PREFIX + '/user/register'
    assert last_response.ok? && (last_response.body.include? 'Register in Nanotwitter')
  end

#  def test_login_correctly
#    get PREFIX + '/login'
#    param = { 'username' => 'jim', 'password' => 'abc' }
#    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
#    assert last_response.ok? 
#  end

  def test_home_logged_in
    get PREFIX + '/login'
    param = { 'username' => 'jim', 'password' => 'abc' }
#    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    post PREFIX + '/login', param

    redirect PREFIX + '/'
    assert last_response.ok?
    assert last_response.body.include?("ago") #Since that's part of a Tweet
  end
#
#  def test_login_incorrectly
#    get '/login'
#    param = { 'username' => 'obviously wrong', 'password' => 'wrong' }
#    post '/login', param.to_json, "CONTENT_TYPE" => "application/json"
#    assert !last_response.ok?
#    assert last_response.body.include?("Wrong password or username.")
#  end
#
#  def test_logout
#    # Need to log in, first.
#    get '/login'
#    param = { 'username' => 'user', 'password' => 'password' }
#    post '/login', param.to_json, "CONTENT_TYPE" => "application/json"
#    redirect '/'
#    assert last_response.ok?
#    assert last_response.body.include?("ago") #Since that's part of a Tweet
#    # Then, log out.
#    post '/logout'
#    assert last_response.ok?
#    get '/'
#    assert last_response.ok?
#    assert last_response.body.include?("Login to Nanotwitter")
#  end
#
#  def test_tweet
#    post '/tweets/new', {:user => 'user', :message => 'I am a test message'}
#    get '/'
#    assert last_response.ok?
#    assert last_response.include?('I am a test message')
#    assert !Tweet.find_by_message('I am a test message').nil?
#  end
#
#  def test_user_page
#    get '/user/user2'
#    assert last_response.ok?
#    assert last_response.body.include?("ago") #Since that's part of a Tweet
#  end
#
#  def test_user_timeline
#    get '/user/user2/timeline'
#    assert last_response.ok?
#    assert last_response.body.include?("ago") #Since that's part of a Tweet
#  end
#
#  def test_user_followers
#    get 'user/user2/followers'
#    assert last_response.ok?
#  end
#
#  def test_user_leaders
#    get 'user/user2/leaders'
#    assert last_response.ok?
#  end
#
#  def test_follow
#    get 'user/user2'
#    assert last_response.ok?
#    post '/user/user2/follow'
#    assert last_response.ok?
#    assert User.find_by_username('user2').followers.include?('user')
#  end
#
#  def test_unfollow
#    get 'user/user2'
#    assert last_response.ok?
#    post '/user/user2/unfollow'
#    assert last_response.ok?
#    assert !User.find_by_username('user2').followers.include?('user')
#  end
#
#  def test_search_hashtags
#    # Not yet implemented
#    get '/search'
#    assert last_response.ok?
#
#  end
#
#  def test_search_users
#    # Not yet implemented
#    get '/search'
#    assert last_response.ok?
#  end
#
#  def test_search_results_fail
#    fail
#  end

end
