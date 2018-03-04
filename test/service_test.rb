require 'minitest/autorun'
require 'rack/test'
require_relative '../service.rb'



class ServiceTest < Minitest::Test

  include Rack::Test::Methods

  def app 
    Sinatra::Application
  end

  def test_get_home
    get '/'
    assert last_response.ok? && (last_response.body.include? 'Login to Nanotwitter') 
  end

  def test_get_login
    get '/login'
    assert last_response.ok? && (last_response.body.include? 'Login to Nanotwitter') && (last_response.body.include? '<form action="/login" method="POST">') 
  end

  def test_get_register
    get '/user/register'
    assert last_response.ok? && (last_response.body.include? 'Register in Nanotwitter') 
  end

  def test_post_login
    skip 'Fix this test later'
    param = { 'username' => '105', 'password' => 'pw' }
    post '/login', param.to_json, "CONTENT_TYPE" => "application/json"
    puts last_response.body
    assert last_response.ok?
    puts last_response.body
    # puts last_response.body

  end



  


  # def test_home
  #   get '/'
  #   # puts last_response.body
  #   assert last_response.ok?
  #   result = (last_response.body.include? 'Login to Nanotwitter') 
  #   assert_equal true, result
  # end


  # describe "test welcome not logined" do
  #   it "should successfully return a welcome" do
  #     get '/'
  #     last_response.body.must_include 'Welcome to Nanotwitter'
  #   end
  # end

  # def test_home_logined

  # end

  

  # def test_login_wrong_person

  # end
  

  # def test_signup 

  # end

  # def test_logout

  # end

end