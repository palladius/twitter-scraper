# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

#require 'ric'
require 'twitter'

#pred "remove Ricc Twitter API keys... use ENV instead maybe with dotenv"

puts "TWITTER_CONSUMER_KEY: #{ENV['TWITTER_CONSUMER_KEY']}. If this was empty, good luck using APIs!"
raise "Missing Twitter key (or exists but is smaller than XX chars: #{ENV['TWITTER_CONSUMER_KEY'].to_s.length}" if ENV['TWITTER_CONSUMER_KEY'].to_s.length < 5
#puts "TEST REMOVEME quando va: ", WordleTweet.extended_wordle_match_type("ciao da Riccardo")

TWITTER_OPTIONS = {
    :api_key =>        ENV['TWITTER_CONSUMER_KEY'],
    :api_key_secret => ENV['TWITTER_CONSUMER_SECRET'],
    :bearer_token => ENV["TWITTER_BEARER_TOKEN"],
  }

# Options

$n_tweets = ENV["TWITTER_INGEST_SIZE"].to_i { 42 }
$rake_seed_import_version = "2"
$check_already_exists = true
$search_terms = [
  '#TwitterParser',
  '#Wordle',
  'Wordle',
  '#Parole',
  'term.ooo',
  '🟩🟩🟩🟩🟩', # success
]

# def nice_twitter_username(twitter_user)
#     u = twitter_user
#     "#{u.screen_name} (#{u.name}, #{u.location})"
#   end

  # def short_twitter_username(twitter_user)
  #   twitter_user.screen_name
  # end


  def rake_seed_parse_keys

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = TWITTER_OPTIONS[:api_key]
      config.consumer_secret     = TWITTER_OPTIONS[:api_key_secret]
    end

    puts "Looking for #{$n_tweets} tweets matching #Wordle hashtag:"
    #client.search('#Wordle OR #TwitterParser').take($n_tweets).each do |tweet|


    $search_terms.each do |search_term|
      puts "+ [API_CALL] Searchin #{$n_tweets} for term '#{search_term}'.."
      n_saved_tweets = 0
      n_saved_users = 0
      client.search(search_term).take($n_tweets).each do |tweet|
        quick_match = WordleTweet.quick_match(tweet.text)
        next unless quick_match
        #puts "+ Habemus matchem 2: '#{tweet.text.gsub("\n"," ")}'"
        wordle_type = WordleTweet.extended_wordle_match_type(tweet.text)
        if not wordle_type.nil?
          #puts "[DEB] Found [#{ wordle_type}] #{short_twitter_username(tweet.user)}:\t'#{( tweet.text.split("\n")[0] )}'" # text[0,30]
          u = tweet.user
          #print "[deb] 1. Creating Twitter user: #{ u.screen_name} (#{u.name}, #{u.location}).."
          tu = TwitterUser.create(
              twitter_id: u.screen_name,
              location:   u.location,
              name:       u.name,
              # added after 1500 were already added :)
              description: u.description,
              id_str:      u.id.to_s, #id_str doesnt work
              # eg @palladius => 17310864
          )
          saved = tu.save
          # TODO(ricc): update Existing with new descriptions even if it already exists
          #puts "1. Created TwitterUser: #{tu} id=#{tu.id rescue :noid}" if saved
          n_saved_users += 1 if saved

          if $check_already_exists
            already_exists = Tweet.find_by_twitter_id(tweet.id)
            puts "- [CACHE] Already exists TODO update if needed: [#{tu}] '#{already_exists.excerpt}' (import v#{already_exists.import_version})" if (
              already_exists && $rake_seed_import_version != already_exists.import_version
            )
          end
          #print "2. [#{tweet.created_at}] Creating Tweet info based on existence of twitter_id :)"
          rails_tweet = Tweet.create(
              twitter_user: TwitterUser.find_by_twitter_id(tweet.user.screen_name) ,
              full_text: tweet.text,
              # 2022-02-06 updated this
              #created_at: tweet.created_at,
#              id: tweet.id,
              twitter_id:  tweet.id,
              twitter_created_at: tweet.created_at,
              import_version: $rake_seed_import_version,
              import_notes: "Now this supports also the timestamp and unique ID of Twitter tweet. Now this has finally LIFE and i can link to original via URL",
              internal_stuff: "TODO mi servira",
              # polymoprhic stuff in case new stuff comes to my mind..
              json_stuff: "{}",
          )
          saved_tweet = rails_tweet.save
          if saved_tweet
            puts "- Non-Trivial Tweet saved: #{rails_tweet.id} from #{rails_tweet.to_s}"  if rails_tweet.wordle_type != "wordle_en"
            n_saved_tweets += 1
          end
        end
        #client.update("@#{tweet.user} Hey I love Ruby too, what are your favorite blogs? :)")
      end
      puts "  - #{n_saved_tweets} saved tweets; #{n_saved_users} new users."
    end

    # tweets = client.user_timeline('rubyinside', count: 20)
    # tweets.each { |tweet| puts tweet.full_text }
  end

rake_seed_parse_keys
