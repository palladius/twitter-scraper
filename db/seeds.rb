# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'json'
require 'socket'
require 'twitter'

def yellow(s)
  "\e[1;33m#{s}\e[0m"
end
def white(s)
  "\e[1;37m#{s}\e[0m"
end
def azure(s)
  "\033[1;36m#{s}\033[0m"
end
#pred "remove Ricc Twitter API keys... use ENV instead maybe with dotenv"

TWITTER_OPTIONS = {
    :api_key =>        ENV['TWITTER_CONSUMER_KEY'],
    :api_key_secret => ENV['TWITTER_CONSUMER_SECRET'],
    :bearer_token => ENV["TWITTER_BEARER_TOKEN"],
  }

# Options
# v1
# v2
# v3 2022-02-15: Added JSON with hostname and..
$n_tweets = (ENV["TWITTER_INGEST_SIZE"] || '42' ).to_i
$rake_seed_import_version = "3"
$check_already_exists = true
$hostname = Socket.gethostname rescue "host_error"
$search_terms = [
  '#TwitterParser',
  #'#Wordle',
  '#Parole',
  'term.ooo',
  'https://term.ooo/',
  'wordlefr',
  'WordleIT',
  'Par🇮🇹le',
  'wordlegame.org', # since 0.11 I support it!
  '#taylordle',
  'katapat',
  'worldle',
  'wordlept',
  'wekele',
  # this works but produces TOO much and i dont know what it i
  #'🟩🟩🟩🟩🟩', # success
  # We keep this last
  'Wordle',
]

# main

def db_seed_puts(str)
  common_header = "[#{white 'DB:SEED'}][#{yellow Rails.env.first(4)}] "
  puts "#{common_header}#{str}"
end

def main
  db_seed_puts "TWITTER_CONSUMER_KEY: #{white ENV['TWITTER_CONSUMER_KEY']}. If this was empty, good luck using APIs!"
  raise "Missing Twitter key (or exists but is smaller than XX chars: #{ENV['TWITTER_CONSUMER_KEY'].to_s.length}" if ENV['TWITTER_CONSUMER_KEY'].to_s.length < 5
  #db_seed_puts "TEST REMOVEME quando va: ", WordleTweet.extended_wordle_match_type("ciao da Riccardo")
  db_seed_puts "N_ITERATIONS from ENV: #{yellow $n_tweets}"
  db_seed_puts "#{white $search_terms.count.to_s } search terms: #{yellow $search_terms}"
  db_seed_puts "Ingesting into this DB: #{yellow Rails.configuration.database_configuration[Rails.env]["adapter"]}"
  db_seed_puts "Stats: #{yellow Tweet.count.to_s} tweets, #{yellow WordleTweet.count.to_s} WTs, #{yellow TwitterUser.count.to_s}  Users"
  #exit 42

  raise "Too few tweets required. Set TWITTER_INGEST_SIZE env var!" if $n_tweets < 1
  rake_seed_parse_keys()
end



def rake_seed_parse_keys

  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = TWITTER_OPTIONS[:api_key]
    config.consumer_secret     = TWITTER_OPTIONS[:api_key_secret]
  end

  puts "Looking for #{$n_tweets} tweets matching #Wordle hashtag:"
  #client.search('#Wordle OR #TwitterParser').take($n_tweets).each do |tweet|


  $search_terms.each do |search_term|
    puts "+ [API_CALL] Searchin #{$n_tweets} for term '#{yellow search_term}'.."
    puts azure("TODO(ricc): include into the boring notes the HOSTNAME #{$hostname} and SEARCH KEY (#{yellow search_term}) possibly in JSOn format")
    n_saved_tweets = 0
    n_unsaved_tweets = 0
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
        hash = {app_ver: APP_VERSION, search_term: search_term, hostname: $hostname}
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
            internal_stuff: "search_term='#{search_term rescue :unknown}'",
            # polymoprhic stuff in case new stuff comes to my mind..
            json_stuff: hash.to_json,
        )
        saved_tweet = rails_tweet.save
        if saved_tweet
          puts "- Non-Trivial Tweet saved: #{rails_tweet.id} from #{rails_tweet.to_s}"  if rails_tweet.wordle_type != "wordle_en"
          n_saved_tweets += 1
        else
          # single error here.
          n_unsaved_tweets += 1
          print '.'
        end
      end
      #client.update("@#{tweet.user} Hey I love Ruby too, what are your favorite blogs? :)")
    end
    puts "  - #{ yellow n_saved_tweets} saved tweets / #{white n_unsaved_tweets} unsaved; #{yellow n_saved_users} new users."
  end

end


main()
