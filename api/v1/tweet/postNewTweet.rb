require 'rest-client'
require 'json'

post PREFIX + '/tweets/new' do
  usr = session[:user_id]
  msg = params[:tweet]['message']
  mentions = Array.new
  hashtags = Array.new

  #byebug
  #hashtag_list =
  #if new_tweet.save
    #mentions_list.each do |mention|
    content = msg.split # Tokenizes the message
    content.each do |token|
      if /([@.])\w+/.match(token)
        term = token[1..-1]
        if User.find_by_username(term)
          mentions << term
        end
      elsif /([#.])\w+/.match(token)
        term = token[1..-1]
        hashtags << term
      end
    end
    #byebug
    #Yes, it must be hard-coded at the moment...
    response = RestClient.post 'https://nt-tweet-writer.herokuapp.com/api/v1/tweets/new', {contents: msg, user_id: usr, hashtags: hashtags.to_json, mentions: mentions.to_json}
    # response = RestClient.post 'http://192.168.33.10:8085//api/v1/tweets/new', {contents: msg, user_id: usr, hashtags: hashtags.to_json, mentions: mentions.to_json}
    resp_hash = JSON.parse(response)
    #byebug
    if resp_hash['saved'] == 'true'
      redirect PREFIX + '/'
    else
      @error = 'Tweet could not be saved'
      redirect PREFIX + '/'
    end

      # if /([@.])\w+/.match(mention)
      #   term = mention[1..-1]
      #   if User.find_by_username(term)
          # new_mention = Mention.new(username: term,tweet_id: new_tweet.id)
          # @error = 'Mention could not be saved' if !new_mention.save
    #     end
    #   end
    # end
    # hashtags_list.each do |hashtag|
    #   if /([#.])\w+/.match(hashtag)
    #     term = hashtag[1..-1]
    #     if !Hashtag.find_by_tag(term)
    #       new_hashtag = Hashtag.new(tag: term)
    #       new_hashtag.save
    #     end
    #     new_hashtag = HashtagTweet.new(hashtag_id: Hashtag.find_by_tag(term).id,tweet_id: new_tweet.id) if Hashtag.exists?(tag:term)
    #     #byebug
    #     @error = 'Mention could not be saved' if !new_hashtag.save
    #   end
    # end
  #   redirect PREFIX + '/'
  # else
  #   @error = 'Tweet could not be saved'
  #   redirect PREFIX + '/'
  # end
end
