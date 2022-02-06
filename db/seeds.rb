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

TWITTER_RICC = {
    :api_key =>        ENV['TWITTER_CONSUMER_KEY'], 
    :api_key_secret => ENV['TWITTER_CONSUMER_SECRET'],
    :bearer_token => ENV["TWITTER_BEARER_TOKEN"],
  }
  
N_TWEETS = 50 # 00


def nice_twitter_username(twitter_user)
    u = twitter_user
    "#{u.screen_name} (#{u.name}, #{u.location})"
  end

  # TODO(ricc): use the Model one which is better :) 
  def extended_wordle_match_type_obsoleto(text, include_very_generic = false, exclude_wordle_english_for_debug=false,
      include_only_italian_for_debug = true )
    # returns TWO things: matches and id of

    ## ITALIAN START
      # ParFlag of Italyle 369 3/6
      # PAR🇮🇹LE
      return :wordle_it1  if text.match?(/Par.*le \d+ .\/6/i)
      # Pietro version Par🇮🇹le 370 1/6 🟩🟩🟩🟩🟩
      # testiamo per poco il 1/2
      return :wordle_it2  if text.match?(/Par🇮🇹le \d+ .\/6/i)
      return :wordle_it3_removeme  if text.match?(/par.+le \d+ .\/6/i)

    ## ITALIAN END
    return nil if include_only_italian_for_debug 

    return :wordle_en  if text.match?(/Wordle \d+ \d\/6/i) unless exclude_wordle_english_for_debug
    return :wordle_fr  if text.match?(/Le Mot \(@WordleFR\) \#\d+ .\/6/i)
    # "joguei http://term.ooo #34 X/6 *"
    return :wordle_pt  if text.match?(/joguei http:\/\/term.ooo \#34 .\/6/i )
    # I cant remember wha website was this.
    return :wordle_de2  if text.match?(/I guessed this German 5-letter word in .\/6 tries/)
    # This is better
    return :wordle_de  if text.match?(/http:\/\/wordle-spielen.de.*WORDLE.*\d+ .\/6/)
    return :lewdle     if text.match?(/Lewdle \d+ .\/6/) 
    
    return :nerdlegame if text.match?(/nerdlegame \d+ .\/6/i)
    
    return :wordle_ko  if text.match?(/#Korean #Wordle .* \d+ .\/6/)

    # Generic wordle - might want to remove in the future
    if include_very_generic
      return :other if text.match?(/ordle \d+ [123456X]\/6/i) unless exclude_wordle_english_for_debug
      return :other2 if text.match?(/🟩🟩🟩🟩🟩/)
    end
    return nil
  end

  def short_twitter_username(twitter_user)
    twitter_user.screen_name
  end


  def real_program
    
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = TWITTER_RICC[:api_key]
      config.consumer_secret     = TWITTER_RICC[:api_key_secret]
    end

    puts "Looking for #{N_TWEETS} tweets matching #Wordle hashtag:"
    #client.search('#Wordle OR #TwitterParser').take(N_TWEETS).each do |tweet|
    search_terms = [
      '#TwitterParser',
      '#Wordle',
    ] 
    search_terms.each do |search_term| 
      puts "Searchin #{N_TWEETS} for term '#{search_term}'.."

      client.search(search_term).take(N_TWEETS).each do |tweet|
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
          # TODO(ricc): update Existing with new descriptions
          puts "1. Created TwitterUser: #{tu}" if saved

          #print "2. [#{tweet.created_at}] Creating Tweet info based on existence of twitter_id :)"
          rails_tweet = Tweet.create(
              twitter_user: TwitterUser.find_by_twitter_id(tweet.user.screen_name) ,
              full_text: tweet.text,
              # 2022-02-06 updated this
              #created_at: tweet.created_at,
#              id: tweet.id,
              twitter_id:  tweet.id,
              twitter_created_at: tweet.created_at,
              import_version: "2",
              import_notes: "Now this supports also the timestamp and unique ID of Twitter tweet. Now this has finally LIFE and i can link to original via URL",
              internal_stuff: "TODO mi servira",
              # polymoprhic stuff in case new stuff comes to my mind..
              json_stuff: "{}",

          )
          saved_tweet = rails_tweet.save 
          print "2. Tweet saved: #{rails_tweet.id} from #{rails_tweet.twitter_user}" if saved_tweet
        end 
        #p tweet.metadata.to_s
        #client.update("@#{tweet.user} Hey I love Ruby too, what are your favorite blogs? :)")
      end
    end
  
    # tweets = client.user_timeline('rubyinside', count: 20)
    # tweets.each { |tweet| puts tweet.full_text }
  end

real_program