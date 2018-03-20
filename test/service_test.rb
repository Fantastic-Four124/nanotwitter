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

  def current_user_session
    get PREFIX + '/', {}, { 'rack.session' => {user_id: current_user.id, user_hash: current_user, username: current_user.username} }
  end

  def current_user
    if User.exists?(username: 'jim')
      return User.where(username: 'jim')[0]
    else
      User.create({username: 'jim', password: 'abc', email: 'jim@jim.com'})
      return User.where(username: 'jim')[0]
    end
  end


  def setup
    current_user_session
    if !User.exists?(username: 'bob')
      User.create({username: 'bob', password: 'abc', email: 'bob@bob.com'})
    end
  end

  def teardown
    jim.destroy
    bob.destroy
  end

  def bob
    User.where(username: 'bob')[0]
  end

  def jim
    current_user
  end

  def test_home
    get PREFIX + '/', {}, { 'rack.session' => {username: nil} }
    assert last_response.ok? && (last_response.body.include? 'Login to nanoTwitter')
  end

  def test_login_page
    get PREFIX + '/', {}, { 'rack.session' => {username: nil} }
    get PREFIX + '/login'
    assert last_response.ok? && (last_response.body.include? 'Login to Nanotwitter') && (last_response.body.include? `<form action="#{PREFIX}/login" method="POST">`)
  end

  def test_registration_page
    get PREFIX + '/', {}, { 'rack.session' => {username: nil} }
    get PREFIX + '/user/register'
    assert last_response.ok? && (last_response.body.include? 'Register in Nanotwitter')
  end

  def test_login_correctly
    get PREFIX + '/', {}, { 'rack.session' => {username: nil} }
    get PREFIX + '/login'
    param = { 'username' => 'jim', 'password' => 'abc' }
    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.ok?
  end

  def test_home_logged_in
    get PREFIX + '/', {}, { 'rack.session' => {username: nil} }
    get PREFIX + '/login'
    param = { 'username' => 'jim', 'password' => 'abc' }
    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    get PREFIX + '/'
    assert last_response.ok?
  end
##
  def test_login_incorrectly
    get PREFIX + '/login'
    param = { 'username' => 'obviously wrong', 'password' => 'wrong' }
    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    assert last_response.body.include?("Wrong password or username.")
  end
##
  def test_logout
#    # Need to log in, first.
    get PREFIX + '/login'
    param = { 'username' => 'jim', 'password' => 'abc' }
    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    get PREFIX + '/'
    assert last_response.ok?
    assert last_response.body.include?("jim") #Since that's part of a Tweet
#    ## Then, log out.
    post PREFIX + '/logout'
    get PREFIX + '/'
    assert last_response.ok?
    assert last_response.body.include?("Login to nanoTwitter")
  end
#
  def test_tweet
    param = { 'username' => 'jim', 'password' => 'abc' }
    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    post PREFIX + '/tweets/new', {:tweet => {message: "I am a test message", mention: '', hashtag: ''}}
    get PREFIX + '/'
    assert last_response.ok?
    assert !Tweet.find_by_message('I am a test message').nil?
    Tweet.find_by_message('I am a test message').destroy
  end
#
  def test_user_page
    get PREFIX + '/login'
    param = { 'username' => 'jim', 'password' => 'abc' }
    post PREFIX + '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    get PREFIX + '/user/' + jim.id.to_s
    assert last_response.ok?
    assert last_response.body.include?("jim") #Since that's part of a Tweet
  end
#
  def test_user_timeline
    get PREFIX + '/user/' + jim.id.to_s + '/timeline'
    assert last_response.ok?
    assert last_response.body.include?("jim") #Since that's part of a Tweet
  end
#
  def test_user_followers
    get PREFIX + '/user/' + jim.id.to_s + '/followers'
    assert last_response.ok?
    assert last_response.body.include?('Followers')
  end
#
  def test_user_leaders
    get PREFIX + '/user/' + jim.id.to_s + '/leaders'
    assert last_response.ok?
    assert last_response.body.include?('Leaders')
  end
#
  def test_follow
    post PREFIX + '/user/' + bob.id.to_s + '/follow'
    assert bob.followers.include?(current_user)
  end
#
  def test_unfollow
    jim.followers.push(bob)
    post PREFIX + '/user/' + bob.id.to_s + '/unfollow'
    assert !bob.followers.include?(current_user)
  end
#
  def test_search_basic
    tweet = Tweet.create(message: 'lol', user_id: bob.id)
    get PREFIX + '/search', {search: 'lol'}
    assert last_response.ok?
    assert last_response.body.include?('lol')
    tweet.destroy
  end
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
