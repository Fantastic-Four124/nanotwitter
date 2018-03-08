require 'sinatra'
require 'sinatra/activerecord'
require 'byebug'
require 'faker' # fake people showing fake love
require_relative 'models/user'
require_relative 'models/hashtag'
require_relative 'models/mention'
require_relative 'models/tweet'
require_relative 'models/hashtag_tweets'
require_relative './version'

# name: testuser
# email: testuser@sample.com
# password: “password”

TESTUSER_NAME = 'testuser'
TESTUSER_EMAIL = 'testuser@sample.com'
TESTUSER_PASSWORD = 'password'
NUMBER_OF_SEED_USERS = 1000
users_hashtable = Array.new(NUMBER_OF_SEED_USERS + 1) # from user_id to user_name
users_hashtable[0] = TESTUSER_NAME


def recreate_testuser
  result = User.new(username: TESTUSER_NAME, password: TESTUSER_PASSWORD).save
  puts "Recreate testuser -> #{result}"
end

# Danger Zone! It will remove everthing in the DB
def clear_all()
  User.destroy_all
  Hashtag.destroy_all
  Mention.destroy_all
  Tweet.destroy_all
  # Hashtag_tweets.destroy_all
end

# What happen when you break up with someone.... ;(
def remove_everything_about(name)
  list_of_activerecords = [
    Follow.find_by(leader_id: name),
    Follow.find_by(user_id: name),
    Mention.find_by(username: name),
    Tweet.find_by(user_id: name),
    User.find_by(username: name)
  ]
  list_of_activerecords.each { |ar| destroy_and_save(ar) }
end

# Helper method, for active record object ONLY!
def destroy_and_save(active_record_object)
  active_record_object.destroy
  active_record_object.save
end

def report_status
  status = {
    'number of users': User.count,
    'number of tweets': Tweet.count,
    'number of follow': Follow.count,
    'Id of Test user': TESTUSER_NAME
  }
  status
end

def generate_code(number)
  charset = Array('A'..'Z') + Array('a'..'z')
  Array.new(number) { charset.sample }.join
end

def get_fake_password
  str = [true, false].sample ? Faker::Fallout.character : ''
  str = str + [true, false].sample ? Faker::Food.dish  : ''
  str = str + [true, false].sample ? Faker::Date.birthday(18, 65) : ''
  str = str + [true, false].sample ? Faker::Kpop.boy_bands : ''
  str.gsub(/\s/,'')
end

post '/test/reset/all' do
  clear_all
  recreate_testuser
end

post '/test/reset/testuser' do
  remove_everything_about(TESTUSER_NAME)
  recreate_testuser
  puts report_status
end

# Report the current version
get '/test/version' do
  "Version: #{Version.VERSION}".to_json
end

# One page report
# How many users, follows, and tweets are there. What is the TestUser’s id
get '/test/status' do
  st = report_status
  st.to_json
end

# Read from seed
# correct format should be /test/reset/standard?tweets=6
post '/test/reset/standard?' do
  puts params
  input = params[:tweets]
  begin
    if params.length == 1
      num = -1 # -1 means no limit
    else
      num = Integer(input) # only load n tweets from seed data
      if num <= 0
        raise ArgumentError, 'Argument is smaller than zero'
      end
    end

    

    # make all new users
    File.open('seeds/users.csv', 'r').each do |line|
      str = line.split(',')
      id = Integer(str[0]) # ID provided in seed, useless for our implementation for now
      name = str[1]
      users_hashtable[id] = name
      if !User.new(username: name, password: get_fake_password).save 
        puts "Entering user: #{name}, id: #{id} failed."
      end
    end
    # make all new users

    # post all tweets
    File.open('seeds/tweets.csv', 'r').each do |line|
      if num > 0
        break if num == 0 # enforce a limit if there is one
      end
      str = line.split(',')
      id = Integer(str[0]) # ID provided in seed, useless for our implementation for now
      text = str[1]
      time_stamp = str[2] # We dont support this for now !!IMPORTANT!!
      if !Tweet.new(user: users_hashtable[id], message: text).save 
        puts "Entering tweet: #{text}, by: #{id} #{users_hashtable[id]} failed."
      end
      num -= 1
    end
    # post all tweets

    # follow
    File.open('seeds/follows.csv', 'r').each do |line|
      str = line.split(',')
      id1 = Integer(str[0]) # ID provided in seed, useless for our implementation for now
      id2 = Integer(str[1])
      follower_follow_leader(users_hashtable[id1], users_hashtable[id2])
    end
    # follow

    result = { 'Result': 'GOOD!', 'status': report_status }
    result.to_json
  rescue
    # Wrong input
    "Something wrong, \nparams = #{params}".to_json
  end
end

# create u (integer) fake Users using faker. Defaults to 1.
# each of those users gets c (integer) fake tweets. Defaults to zero.
# Example: /test/users/create?count=100&tweets=5
post '/test/users/create?' do
  input_count = params[:count]
  input_tweet = params[:tweets]
  begin
    count = Integer(input_count)
    tweet = Integer(input_tweet)
    # Making fake ppl
    while count > 0
      fake_ppl = Faker::Name.first_name + Faker::Name.last_name + generate_code(5)
      if !User.new(username: fake_ppl, password: get_fake_password).save 
        puts "Enter fake user: #{fake_ppl} failed."
      end
      users_hashtable << fake_ppl
    end
    # Making of fake ppl

    # Fake tweets
    while count > 0
      fake_ppl = Faker::Name.first_name + Faker::Name.last_name + generate_code(5)
      if !User.new(username: fake_ppl, password: get_fake_password).save 
        puts "Enter fake user: #{fake_ppl} failed."
      end
      users_hashtable << fake_ppl
      count -= 1
    end 

    # Fake tweets
    while tweet.positive?
      txts = [
        Faker::Pokemon.name + 'uses' + Faker::Pokemon.move,
        Faker::SiliconValley.quote,
        Faker::SiliconValley.motto,
        Faker::ProgrammingLanguage.name + 'is the best!',
        'I went to ' + Faker::University.name + '.',
        'Lets GO! ' + Faker::Team.name
      ]
      if !Tweet.new(user: users_hashtable.sample, message: txts.sample).save 
        puts 'Fake tweet Failed.'
      end
      tweet -= 1
    end
    # Fake tweets

    "GOOD:\n\tFaking #{count} users and #{tweet} tweets".to_json
  rescue
    # Wrong input
    "Nah, input is not valid, \nparams = #{params}".to_json
  end
end

# user u generates t(integer) new fake tweets
post '/test/user/:user/tweets?' do
  puts params
  input_user = params[:user] # who
  input_count = params[:count]
  begin
    count = Integer(input_count) # number of fake tweets needed to generate
    # TODO: DO SOMETHING
    # TODO: DO SOMETHING
    # TODO: DO SOMETHING
    'TODO'.to_json
  rescue
    # Wrong input
    "Nah, input is not valid, \nparams = #{params}".to_json
  end
  
end


