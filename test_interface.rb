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

# /test/reset/all                   OJBK
# /test/reset/testuser              OJBK
# /test/version                     OJBK
# /test/status                      OJBK
# /test/reset/standard?             ojbk
# /test/users/create?               ? 
# /test/user/u/tweets?count=t       X
# /test/user/u/follow?count=n       X
# /test/user/follow?count=n         X

### Vars
TESTUSER_NAME = 'testuser'
TESTUSER_EMAIL = 'testuser@sample.com'
TESTUSER_PASSWORD = 'password'
NUMBER_OF_SEED_USERS = 1000
TESTUSER_ID = 3456 # The test user will always have 3456
RETRY_LIMIT = 15

### Vars

### Helper Methods
def recreate_testuser
  result = User.new(id: TESTUSER_ID, username: TESTUSER_NAME, password: TESTUSER_PASSWORD, email:TESTUSER_EMAIL).save
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
def remove_everything_about_testuser
  list_of_activerecords = [
    Follow.find_by(leader_id: TESTUSER_ID),
    Follow.find_by(user_id: TESTUSER_ID),
    Mention.find_by(username: TESTUSER_NAME),
    Tweet.find_by(user_id: TESTUSER_ID),
    User.find_by(username: TESTUSER_NAME)
  ]
  list_of_activerecords.each { |ar| destroy_and_save(ar) }
end

# Helper method, for active record object ONLY!
def destroy_and_save(active_record_object)
  return if active_record_object == nil
  active_record_object.destroy
  active_record_object.save
end

def report_status
  status = {
    'number of users': User.count,
    'number of tweets': Tweet.count,
    'number of follow': Follow.count,
    'Id of Test user': TESTUSER_ID
  }
  status
end

def generate_code(number)
  charset = Array('A'..'Z') + Array('a'..'z')
  Array.new(number) { charset.sample }.join
end

def get_fake_password
  str = [true, false].sample ? Faker::Fallout.character : ''
  str += str + ([true, false].sample ? Faker::Food.dish  : '')
  str += ([true, false].sample ? Faker::Kpop.boy_bands : '')
  str.gsub(/\s/, '')
end
### Helper Methods

post '/test/reset/all' do
  clear_all
  recreate_testuser
  report_status.to_json
end

post '/test/reset/testuser' do
  remove_everything_about_testuser
  recreate_testuser
  report_status.to_json
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
  clear_all

  if params.length == 1
    num = -1 # -1 means no limit
  else
    num = Integer(input) # only load n tweets from seed data
    if num <= 0
      raise ArgumentError, 'Argument is smaller than zero'
    end
  end
  users_hashtable = Array.new(NUMBER_OF_SEED_USERS + 1) # from user_id to user_name
  users_hashtable[0] = TESTUSER_NAME

  # make all new users
  File.open('./seeds/users.csv', 'r').each do |line|
    str = line.split(',')
    uid = Integer(str[0]) # ID provided in seed, useless for our implementation for now
    name = str[1].gsub(/\n/, "")
    name = name.gsub(/\r/, "")
    pw = get_fake_password
    users_hashtable[uid] = name
    i = RETRY_LIMIT
    while !User.new(id: uid, username: name, password: pw).save 
      break if i.negative?
      puts "Entering user: #{name}, id: #{uid} failed, and retry."
      i -= 1
    end
  end
  # make all new users
  puts 'users done'

   # follow
   File.open('./seeds/follows.csv', 'r').each do |line|
    str = line.split(',')
    id1 = Integer(str[0]) # ID provided in seed, useless for our implementation for now
    id2 = Integer(str[1])
    puts "#{id1} fo #{id2}"
    follower_follow_leader(id1, id2)
  end
  # follow
  puts 'following done'
  
  # post all tweets
  File.open('./seeds/tweets.csv', 'r').each do |line|
    break if num == 0 # enforce a limit if there is one
    
    str = line.split(',')
    id = Integer(str[0])
    text = str[1]
    time_stamp = str[2]
    i = RETRY_LIMIT
    while !Tweet.new(user_id: id, message: text, timestamps: time_stamp).save 
      break if i.negative?
      puts "Entering tweet: #{text}, by: #{id} #{users_hashtable[id]} failed and retry."
      i -= 1
    end
    num -= 1
  end
  # post all tweets

  recreate_testuser

  result = { 'Result': 'GOOD!', 'status': report_status }
  result.to_json

end

# create u (integer) fake Users using faker. Defaults to 1.
# each of those users gets c (integer) fake tweets. Defaults to zero.
# Example: /test/users/create?count=100&tweets=5
post '/test/users/create?' do
  input_count = params[:count]
  input_tweet = params[:tweets]
  count = Integer(input_count)
  tweet = Integer(input_tweet)
  # Making fake ppl
  # while count > 0
  #   fake_ppl = Faker::Name.first_name + Faker::Name.last_name + generate_code(5)
  #   if !User.new(username: fake_ppl, password: get_fake_password).save 
  #     puts "Enter fake user: #{fake_ppl} failed."
  #   end
  #   users_hashtable << fake_ppl
  # end
  # Making of fake ppl
  puts 'Done faking users'
  # Fake tweets
  users_ids = Array.new(count)
  while count.positive?
    fake_ppl = Faker::Name.first_name + Faker::Name.last_name + generate_code(5)
    neo = User.new(username: fake_ppl, password: get_fake_password)
    if neo.save
      users_ids[count - 1] = neo.id
      puts neo.id
    end
    count -= 1
  end
  # Fake tweets
  puts 'Done faking users'
  make_fake_tweets(users_ids.sample, tweet)
  # Fake tweets
  "GOOD".to_json
end

def make_fake_tweets(user_id, num)
  while num.positive?
    txts = [
      Faker::Pokemon.name + 'uses' + Faker::Pokemon.move,
      Faker::SiliconValley.quote,
      Faker::SiliconValley.motto,
      Faker::ProgrammingLanguage.name + 'is the best!',
      'I went to ' + Faker::University.name + '.',
      'Lets GO! ' + Faker::Team.name
    ]
    msg = txts.sample
    puts "Faking tweet -> #{user_id}: #{msg}"
    if !Tweet.new(user_id: user_id, message: msg).save 
      puts 'Fake tweet Failed.'
    end
    num -= 1
  end
  puts 'Done faking tweets'
end

# user u generates t(integer) new fake tweets
post '/test/user/:user/tweets?' do
  puts params
  input_user = params[:user] # who
  input_count = params[:count]
  begin
    count = Integer(input_count) # number of fake tweets needed to generate



    'TODO'.to_json
  rescue
    # Wrong input
    "Nah, input is not valid, \nparams = #{params}".to_json
  end
end


