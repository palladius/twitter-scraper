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


N_TWEETS = 10


def nice_twitter_username(twitter_user)
    u = twitter_user
    "#{u.screen_name} (#{u.name}, #{u.location})"
  end

  def extended_wordle_match_type(text, include_very_generic = true, exclude_wordle_english_for_debug=false)
    # returns TWO things: matches and id of
    return :wordle_en  if text.match?(/Wordle \d+ \d\/6/i) unless exclude_wordle_english_for_debug
    return :wordle_fr  if text.match?(/Le Mot \(@WordleFR\) \#\d+ .\/6/i)
    # "joguei http://term.ooo #34 X/6 *"
    return :wordle_pt  if text.match?(/joguei http:\/\/term.ooo \#34 .\/6/i )
    # I cant remember wha website was this.
    return :wordle_de2  if text.match?(/I guessed this German 5-letter word in .\/6 tries/)
    # This is better
    return :wordle_de  if text.match?(/http:\/\/wordle-spielen.de.*WORDLE.*\d+ .\/6/)
    return :lewdle     if text.match?(/Lewdle \d+ .\/6/) 
    
    # ParFlag of Italyle 369 3/6
    return :wordle_it  if text.match?(/Par.le \d+ .\/6/)
    return :nerdlegame if text.match?(/nerdlegame \d+ .\/6/i)
    
    return :wordle_ko  if text.match?(/#Korean #Wordle .* \d+ .\/6/)

    # Generic wordle - might want to remove in the future
    if include_very_generic
      return :other if text.match?(/ordle \d+ [123456X]\/6/i) unless exclude_wordle_english_for_debug
    end
    return nil
  end

  def short_twitter_username(twitter_user)
    twitter_user.screen_name
  end


  def real_program
    
    client = Twitter::REST::Client.new do |config|
      #config.consumer_key        = TWITTER_RICC[:api_key]
      #config.consumer_secret     = TWITTER_RICC[:api_key_secret]
    end

    puts "Looking for #{N_TWEETS} tweets matching #Wordle hashtag:"
    client.search('#Wordle OR #TwitterParser').take(N_TWEETS).each do |tweet|
      wordle_type = extended_wordle_match_type(tweet.text)
      if not wordle_type.nil?
        p "+ [#{ wordle_type}] #{short_twitter_username(tweet.user)}:\t'#{( tweet.text.split("\n")[0] )}'" # text[0,30]
        
        u = tweet.user
        print "1. Creating Twitter user: #{ u.screen_name} (#{u.name}, #{u.location}).."
        tu = TwitterUser.create(twitter_id: u.screen_name, location: u.location, name: u.name).save
        print "tu: #{tu}"

        print "2. Creating Tweet info based on existence of twitter_id :)"
        rails_tweet = Tweet.create(
            twitter_user: TwitterUser.find_by_twitter_id(tweet.user.screen_name) ,
            full_text: tweet.text,
        ).save 
        print "Tweet: #{rails_tweet}"
      end 
      #p tweet.metadata.to_s
      #client.update("@#{tweet.user} Hey I love Ruby too, what are your favorite blogs? :)")
    end
  
    # tweets = client.user_timeline('rubyinside', count: 20)
    # tweets.each { |tweet| puts tweet.full_text }
  end

real_program