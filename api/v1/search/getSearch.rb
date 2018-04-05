get PREFIX + '/search' do
  @curr_user = session[:user_hash]
  term = params[:search]
  if term
    @no_term = false
    if /([@.])\w+/.match(term)
      term = term[1..-1]
      @results = User.where("username like ?", "%#{term}%")
      @user_search = true
    elsif /([#.])\w+/.match(term)
      @results = JSON.parse(RestClient.get 'https://nt-tweet-reader.herokuapp.com/api/v1/hashtags/:term', {params: {label: term}})
      # @results = JSON.parse(RestClient.get 'http://192.168.33.10:8090/api/v1/hashtags/:term', {params: {label: term}})
      @user_search = false
    else
      @results = JSON.parse(RestClient.get 'https://nt-tweet-reader.herokuapp.com/api/v1/hashtags/:term', {params: {label: term}})
      # @results = JSON.parse(RestClient.get 'http://192.168.33.10:8090/api/v1/searches/:term', {params: {word: term}})
      @user_search = false
    end
  else
    @no_term = true
    @results = []
  end
  erb :search_results
end
