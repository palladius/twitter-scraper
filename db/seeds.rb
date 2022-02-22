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

TWITTER_OPTIONS = {
    :api_key =>        ENV['TWITTER_CONSUMER_KEY'],
    :api_key_secret => ENV['TWITTER_CONSUMER_SECRET'],
    :bearer_token => ENV["TWITTER_BEARER_TOKEN"],
  }

# Options
# v1
# v2
# v3 2022-02-15: Added JSON with hostname and..
# v4 2022-02-18: Added POLYMOPRH_BEGIN to Tweet - adding from object i seralized in tmp/marshal/ WOOT!
# v5 2022-02-19: moved code execution in model/concerns so it can be run also by a Runner. changed just description and debugging output.

$n_tweets = (ENV["TWITTER_INGEST_SIZE"] || '42' ).to_i
$rake_seed_import_version = "5"
$check_already_exists = true
$lets_try_async_runners = Rails.env == 'development' # only in dev
$hostname = Socket.gethostname.split('.')[0] rescue "hostname_error" #shotname
$search_terms = [
  'joguei https://t.co',
  'k4rlheinz', # Julio
  '#TwitterParser',
  '#Wordle',
  '#Parole',
  'mathler.com',
#  'https://term.ooo/',
  'wordlefr',
  'WordleIT',
  'wordlept',
  'wordle.uber.space',
  'Par🇮🇹le',
  'I guessed this 5-letter word in', #  'wordlegame.org', # since 0.11 I support it!
  '#taylordle',
  'katapat',
  'worldle',
  'wekele',
  'quordle',
  # this works but produces TOO much and i dont know what it i
  #'🟩🟩🟩🟩🟩', # success
  # We keep this last
  'Wordle',
]
$async_wordle_search_terms = %w{ wordle wordlees wordleo #wordleparser }
$marshal_on_file = (ENV["MARSHAL_TO_FILE"] =='true' || false ) rescue false
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
  db_seed_puts "Stats: $marshal_on_file activated! Look into logs/ " if $marshal_on_file
  #exit 42

  raise "Too few tweets required. Set TWITTER_INGEST_SIZE env var!" if $n_tweets < 1
  if $lets_try_async_runners
    $async_wordle_search_terms.each do |delayed_word|
      Tweet.delay.seed_by_calling_twitter_apis(
        delayed_word,  
        $n_tweets, {
          :description => 'DELAYED call from db:seed'
      })
      end 
  else
      puts "We'll skip async runners since they seem to clog in dev and return TOO MANY APU CALLS :) and kill everyone else :)"
    end
  # Tweet.seed_by_calling_twitter_apis('#wordle',  $n_tweets, {
  #   :description => 'call from db:seed to NON-delayed task on Model directly..'
  # })

  rake_seed_parse_keys_simplified
end

def rake_seed_parse_keys_simplified()
  puts(green("This is the new code! It uses the Tweet.first.load_from_twitter concern - wOOt!"))

  # client = Twitter::REST::Client.new do |config|
  #   config.consumer_key        = TWITTER_OPTIONS[:api_key]
  #   config.consumer_secret     = TWITTER_OPTIONS[:api_key_secret]
  # end

  puts "Looking for #{$n_tweets} tweets matching #Wordle hashtag:"

  intermediate_search_term = ENV.fetch 'SEARCH_ONLY_FOR', nil 
  search_terms = intermediate_search_term.nil? ?
    $search_terms :               # Global thingy
    [ intermediate_search_term]   # local if you provide $SEARCH_ONLY_FOR
  puts "Searching for these keywords: #{azure search_terms.join(', ')}"
  debug = ENV.fetch 'DEBUG', nil
  search_terms.each do |search_term|
    ret = Tweet.seed_by_calling_twitter_apis(
      search_term,  
      $n_tweets, {
        :description => 'DIRECT (non-delayed) call from db:seed',
        :debug => (not debug.nil?) ,
    })
    puts "rake_seed_parse_keys_simplified: ret=#{ret}"
  end

end


# def rake_seed_parse_keys
#   puts(red("This is being deprecated now! Use Tweet.first. load_from_twiitter concern!"))

#   client = Twitter::REST::Client.new do |config|
#     config.consumer_key        = TWITTER_OPTIONS[:api_key]
#     config.consumer_secret     = TWITTER_OPTIONS[:api_key_secret]
#   end

#   puts "Looking for #{$n_tweets} tweets matching #Wordle hashtag:"
#   #client.search('#Wordle OR #TwitterParser').take($n_tweets).each do |tweet|


#   $search_terms.each do |search_term|
#     puts "[🐦 API_CALL] Searchin #{white $n_tweets} for term '#{azure search_term}'.."
#     #puts azure("TODO(ricc): include into the boring notes the HOSTNAME #{$hostname} and SEARCH KEY (#{yellow search_term}) possibly in JSOn format")
#     n_saved_tweets = 0
#     n_unsaved_tweets = 0
#     n_saved_users = 0
#     client.search(search_term).take($n_tweets).each do |tweet|
#       quick_match = WordleTweet.quick_match(tweet.text)
#       next unless quick_match
#       if $marshal_on_file # then
#         m = tweet
#         path = File.expand_path('./tmp/marshal/')
# #        myhash = tweet.hash # todo change to something unique but always the same for same tweet like twit id.
#         myhash = [tweet.user.screen_name , tweet.id].join("-")
#         puts "[$marshal_on_file] Habemus Matchem 2 [pat=#{path}]: '#{tweet.text.gsub("\n"," ")}'"
#         File.open("#{path}/dumpv10-#{myhash}.yaml", 'w') { |f| f.write(YAML.dump(m)) }
#         File.open("#{path}/dumpv10-#{myhash}.obj", 'wb') { |f| f.write(Marshal.dump(m)) }
#         #puts 'DEBUG END AFTER ONE until it works :)'
#         #exit 42
#       end
#       wordle_type = WordleTweet.extended_wordle_match_type(tweet.text)
#       if not wordle_type.nil?
#         #puts "[DEB] Found [#{ wordle_type}] #{short_twitter_username(tweet.user)}:\t'#{( tweet.text.split("\n")[0] )}'" # text[0,30]
#         u = tweet.user
#         #print "[deb] 1. Creating Twitter user: #{ u.screen_name} (#{u.name}, #{u.location}).."
#         tu = TwitterUser.create(
#             twitter_id: u.screen_name,
#             location:   u.location,
#             name:       u.name,
#             # added after 1500 were already added :)
#             description: u.description,
#             id_str:      u.id.to_s, #id_str doesnt work
#             # eg @palladius => 17310864
#             # consider adding:
#             # *    :profile_image_url: http://pbs.twimg.com/profile_images/2448864122/jicix70clvqqeazgdxh3_normal.jpeg
#             # *    :created_at: Tue Nov 11 14:48:00 +0000 2008

#         )
#         saved = tu.save
#         # TODO(ricc): update Existing with new descriptions even if it already exists
#         #puts "1. Created TwitterUser: #{tu} id=#{tu.id rescue :noid}" if saved
#         n_saved_users += 1 if saved

#         if $check_already_exists
#           already_exists = Tweet.find_by_twitter_id(tweet.id)
#           #puts "- [CACHE] Already exists TODO update if needed: [#{tu}] '#{already_exists.excerpt}' (import v#{already_exists.import_version})"
#           print 'c' if (already_exists && $rake_seed_import_version != already_exists.import_version)
#           next if already_exists
#         end
#         #print "2. [#{tweet.created_at}] Creating Tweet info based on existence of twitter_id :)"
#         hash = {
#             app_ver: APP_VERSION, 
#             search_term: search_term,
           
#             # POLYMOPRH_BEGIN polymorphically adding this
#             twitter_retweeted:  (tweet.retweeted rescue nil),
#             twitter_lang:  (tweet.lang rescue nil),
#             twitter_retweet_count:  (tweet.retweet_count rescue nil),
#             # POLYMOPRH_END            
          
#             hostname: $hostname
#         } # I know - but it helps with commas :)
#         rails_tweet = Tweet.create(
#             twitter_user: TwitterUser.find_by_twitter_id(tweet.user.screen_name) ,
#             full_text: tweet.text,
#             # 2022-02-06 updated this
#             #created_at: tweet.created_at,
# #              id: tweet.id,
#             twitter_id:  tweet.id,
#             twitter_created_at: tweet.created_at,
#             import_version: $rake_seed_import_version,
#             import_notes: "Now this supports also the timestamp and unique ID of Twitter tweet. Now this has finally LIFE and i can link to original via URL.
#             On 18feb Ive added 3 tweet object aspects i found in Marshalling. The onmly one that works is language, NTS.",
#             internal_stuff: "search_term='#{search_term rescue :unknown}'",
#             # polymoprhic stuff in case new stuff comes to my mind..
#             json_stuff: hash.to_json,
#         )
#         saved_tweet = rails_tweet.save
#         if saved_tweet
#           puts "- Non-Trivial #{yellow rails_tweet.wordle_type} Tweet saved: #{rails_tweet.id} from #{rails_tweet.to_s}"  if rails_tweet.wordle_type != "wordle_en"
#           n_saved_tweets += 1
#         else
#           # single error here.
#           n_unsaved_tweets += 1
#           print 'e' # putchar
#         end
#       end
#       #client.update("@#{tweet.user} Hey I love Ruby too, what are your favorite blogs? :)")
#     end
#     puts "  - #{ yellow n_saved_tweets} saved tweets / #{white n_unsaved_tweets} unsaved; #{yellow n_saved_users} new users."
#   end

# end


main()
