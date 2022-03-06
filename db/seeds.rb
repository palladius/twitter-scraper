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

# Options
# v1
# v2
# v3 2022-02-15: Added JSON with hostname and..
# v4 2022-02-18: Added POLYMOPRH_BEGIN to Tweet - adding from object i seralized in tmp/marshal/ WOOT!
# v5 2022-02-19: moved code execution in model/concerns so it can be run also by a Runner. changed just description and debugging output.

def db_seed_puts(str)
  common_header = "[#{white 'DB:SEED'}][#{yellow Rails.env.first(4)}] "
  puts "#{common_header}#{str}"
end

def main

  intermediate_search_term = ENV.fetch 'SEARCH_ONLY_FOR', nil
  n_tweets = ENV.fetch("TWITTER_INGEST_SIZE", '42').to_i
  #delayed_async_runners = Rails.env == 'development' # only in dev
  delayed_async_runners = (ENV.fetch "MARSHAL_TO_FILE", 'false').to_s.upcase == 'TRUE' 
  async_wordle_search_terms = %w{ wordle wordlees wordleo #wordleparser }
  marshal_on_file = ENV.fetch("MARSHAL_TO_FILE", :false).to_s.upcase == 'TRUE' # rescue false
  search_terms = [
    'joguei https://t.co',
    'k4rlheinz', # Julio
    '#TwitterParser',
    '#Wordle',
    'wordle.at', 'Wördl',
    '@dewordle', # 
    '#Parole',
    'mathler.com',
    'mathler',
    '#mathler',
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
    (Rails.env == 'development' ? nil : 'Wordle'),
  ].select{|x| not x.nil?}
  # if intermediate_search_term, change to 1 :)
  search_terms = intermediate_search_term.nil? ?
  search_terms :               # Global thingy
  [ intermediate_search_term]   # local if you provide $SEARCH_ONLY_FOR



  db_seed_puts "TWITTER_CONSUMER_KEY: #{white ENV['TWITTER_CONSUMER_KEY']}. If this was empty, good luck using APIs!"
  raise "Missing Twitter key (or exists but is smaller than XX chars: #{ENV['TWITTER_CONSUMER_KEY'].to_s.length}" if ENV['TWITTER_CONSUMER_KEY'].to_s.length < 5
  #db_seed_puts "TEST REMOVEME quando va: ", WordleTweet.extended_wordle_match_type("ciao da Riccardo")
  db_seed_puts "N_ITERATIONS from ENV: #{yellow n_tweets}"
  db_seed_puts "#{white search_terms.count.to_s } search terms: #{yellow search_terms}"
  db_seed_puts "Ingesting into this DB: #{yellow Rails.configuration.database_configuration[Rails.env]["adapter"]}"
  db_seed_puts "Stats: #{yellow Tweet.count.to_s} tweets, #{yellow WordleTweet.count.to_s} WTs, #{yellow TwitterUser.count.to_s}  Users"
  db_seed_puts "Stats: marshal_on_file activated! Look into logs/ " if marshal_on_file
  #exit 42

  ActiveRecord::Base.logger = Logger.new(STDOUT)

  raise "Too few tweets required. Set TWITTER_INGEST_SIZE env var!" if n_tweets < 1
  if delayed_async_runners
    async_wordle_search_terms.each do |delayed_word|
      Tweet.delay.seed_by_calling_twitter_apis(
        delayed_word,
        n_tweets, {
          :description => 'DELAYED call from db:seed'
      })
      end
  else
      puts "We'll skip async runners since they seem to clog in dev and return TOO MANY APU CALLS :) and kill everyone else :)"
    end
  #puts(green("This is the new code! It uses the Tweet.first.load_from_twitter concern - wOOt!"))
  #puts "Looking for #{n_tweets} tweets matching #Wordle hashtag:"

  

  puts "Searching for these keywords: #{azure search_terms.join(', ')}"
  debug = ENV.fetch 'DEBUG', nil
  opts = {
    :description => 'DIRECT (non-delayed) call from db:seed',
    :debug => (not debug.nil?) ,
  }
  search_terms.each do |search_term|
    ret = Tweet.seed_by_calling_twitter_apis(
      search_term,
      n_tweets, 
      opts)
    puts "rake_seed_parse_keys_simplified: ret=#{ret}"
  end

end


main()
