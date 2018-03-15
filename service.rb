require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'
require 'time_difference'
require 'time'
require_relative 'models/follow'
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

def follower_follow_leader(follower_id,leader_id)
  link = Follow.find_by(user_id: follower_id, leader_id: leader_id)
  if link.nil?
      relation = Follow.new
      relation.user_id = follower_id
      relation.leader_id = leader_id
      relation.follow_date = Time.now
      relation.save

      follower = User.find(follower_id)
      leader = User.find(leader_id)

      follower.number_of_leaders += 1
      leader.number_of_followers += 1
      follower.save
      leader.save

      return relation
    end
end

def follower_unfollow_leader(follower_id,leader_id)
  link = Follow.find_by(user_id: follower_id, leader_id: leader_id)
  if !link.nil?
      Follow.delete(link.id)

      follower = User.find(follower_id)
      leader = User.find(leader_id)

      follower.number_of_leaders -= 1
      leader.number_of_followers -= 1
      follower.save
      leader.save

      return Follow.find_by(user_id: follower_id, leader_id: leader_id)
    end
end

get '/loaderio-1541f51ead65ae3319ad8207fee20f8d.txt' do
  send_file 'loaderio-1541f51ead65ae3319ad8207fee20f8d.txt'
end

get '/login' do
  if protected!
    redirect '/'
  else
    erb :login
  end
end

post '/login' do
  @user = User.find_by_username(params['username'])
  if !@user.nil? && @user.password == params['password']
    session[:username] = params['username']
    session[:password] = params['password']
    session[:user_id] = @user.id
    session[:user_hash] = @user
    redirect '/'
  else
    @texts = 'Wrong password or username.'
    erb :login
  end
end

# All other pages need to have these session objects checked.
get '/' do
  if protected!
    #@curr_user = session[:user_hash]
    # The number will be dynamically changing. We should think about how to change
    @curr_user = User.find(session[:user_id])
    tweets = Tweet.where("user_id = '#{session[:user_id]}'").sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..49]
    erb :logged_root
  else
    tweets = Tweet.all.sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..49]
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
  @user = User.new(username: username)
  @user.password = password
  @user.number_of_followers = 0
  @user.number_of_leaders = 0
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

get '/user/:user_id' do
  if protected!
    @curr_user = User.find(params['user_id'])
    tweets = Tweet.where("user_id = '#{@curr_user.id}'").sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..49]
    erb :tweet_feed
  else
    redirect '/'
  end
end

get '/user/:user_id/followers' do
  if protected!
    #TODO: implement followers/leaders; right now using user #2 as dummy
    @curr_user = User.find(params['user_id'])
    #follower_list = @curr_user.followers
    @user_list = @curr_user.followers
    #@user_list << follower
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
    #leader_list = @curr_user.leaders
    @user_list = @curr_user.leaders
    #@user_list << follower
    @title = 'Leaders'
    erb :user_list
  else
    redirect '/'
  end
end

get '/user/:user_id/timeline' do
  if protected!
    @curr_user = User.find(params['user_id'])
    leader_list = @curr_user.leaders
    tweets = []
    leader_list.each do |leader|
      subtweets = Tweet.where("user_id = '#{leader.id}'")
      tweets.push(*subtweets)
    end
    tweets.sort_by &:created_at
    tweets.reverse!
    @tweets = tweets[0..49]
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

get '/hashtag/:hashtag_id' do
  @curr_user = session[:user_hash]
  @no_term = false
  all_tweet_ids = HashtagTweet.where(:hashtag_id => params['hashtag_id']).pluck(:tweet_id)
  @results = Tweet.where(id: all_tweet_ids).sort_by &:created_at
  @results.reverse!
  @user_search = false
  erb :search_results
end

post '/tweets/new' do
  usr = session[:user_hash]
  msg = params[:tweet]['message']
  mentions = params[:tweet]['mention']
  hashtags = params[:tweet]['hashtag']
  new_tweet = Tweet.new(user: usr, message: msg)
  mentions_list = mentions.split(" ")
  hashtags_list = hashtags.split(" ")
  #hashtag_list =
  if new_tweet.save
    mentions_list.each do |mention|
      if /([@.])\w+/.match(mention)
        term = mention[1..-1]
        if User.find_by_username(term)
          new_mention = Mention.new(username: term,tweet_id: new_tweet.id)
          @error = 'Mention could not be saved' if !new_mention.save
        end
      end
    end
    hashtags_list.each do |hashtag|
      if /([#.])\w+/.match(hashtag)
        term = hashtag[1..-1]
        if !Hashtag.find_by_tag(term)
          new_hashtag = Hashtag.new(tag: term)
          new_hashtag.save
        end
        new_hashtag = HashtagTweet.new(hashtag_id: Hashtag.find_by_tag(term).id,tweet_id: new_tweet.id) if Hashtag.exists?(tag:term)
        byebug
        @error = 'Mention could not be saved' if !new_hashtag.save
      end
    end
    redirect '/'
  else
    @error = 'Tweet could not be saved'
    redirect '/'
  end
end

post "/user/:user_id/follow" do
    follower_id = session[:user_id]
    leader_id = params['user_id'].to_i
    check = follower_follow_leader(follower_id,leader_id)
    if check
        redirect "/user/#{params['user_id']}"
    else
        'repeated follow'
    end
end

post "/user/:user_id/unfollow" do
    follower_id = session[:user_id]
    leader_id = params['user_id'].to_i
    uncheck = follower_unfollow_leader(follower_id,leader_id)
    if !uncheck
        redirect "/user/#{params['user_id']}"
    else
        'repeated unfollow'
    end
end
