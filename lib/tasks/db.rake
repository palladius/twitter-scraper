# created with: rails g task db sbirciatina popola

def envputs(s)
  puts "[#{Rails.env}] #{s}"
end


def yellow(s)
  "\e[1;33m#{s}\e[0m"
end
def white(s)
  "\e[1;37m#{s}\e[0m"
end

def write_entity_cardinalities()
  t0 = Time.now
  envputs "ENV:     #{Rails.env}     BEGIN=#{t0}"
  envputs "Tweets:  #{Tweet.all.count}"
  envputs "Users:   #{TwitterUser.all.count}"
  envputs "WTweets: #{WordleTweet.all.count}"
  #envputs "Total time: END=#{Time.now} - delta=#{Time.now-t0}sec"
  envputs "Total time: delta=#{Time.now-t0}sec"
end

namespace :db do
  desc "take a quick look at whats inside :)"
  task sbirciatina: :environment do

      write_entity_cardinalities

  end

  desc "popola in test"
  task popola_test: :environment do
    raise "Funge solo in TEST!!" unless Rails.env == "test"
    envputs 'TODO(ricc): move to proper rake tests'

    #write_entity_cardinalities
    envputs 'Calling post-creation callbacks (which doesnt happen by defaault with TEST fixtures for efficiency reasons)..'
    Tweet.all.each {|t| t._run_create_callbacks}
    #write_entity_cardinalities

    # Types: WordleTweet.group(:wordle_type).count

    tweet_types = WordleTweet.group(:wordle_type).count
    envputs "Twitter types: #{tweet_types}"
    envputs "Acceptable types: #{WordleTweet.acceptable_types}" 
    
    envputs " == WordleTweets =="
    WordleTweet.all.each { |wt|
      envputs "+ [#{wt.valid? ? :OK : :INVALID }] #{wt.flag} T='#{yellow wt.wordle_type}' day=#{white wt.parse_incrementalday_from_text} expected_is=#{yellow(wt.tweet.internal_stuff) rescue :nada}"
    }
    puts("WT types: #{ WordleTweet.all.map{|wt| wt.wordle_type}.join(", ") }")
    puts("WT Flags: #{WordleTweet.all.map{|wt| wt.flag}.join(", ")}")
    envputs " == WordleTweets ERRORS =="
    n_errors = 0
    n_invalids = 0
    WordleTweet.all.each { |wt|
      #bad_type = wt.wordle_type.to_s.in? ['', 'unknown_v2']
      unless wt.wordle_type.in?(WordleTweet.acceptable_types)
        envputs "[BAD1] #{wt.flag} type='#{yellow  wt.wordle_type}' score=#{yellow wt.score} day='#{yellow wt.parse_incrementalday_from_text}' MagicInfo='#{yellow(wt.tweet.internal_stuff) rescue :nada}'"
        envputs "[BAD2] TXT='#{white wt.tweet.full_text.gsub("\n",'') }'"
        n_errors += 1
        wt.validate
        n_invalids += 1 unless wt.valid?
      end
    }
    puts "END. Total Errors: #{yellow n_errors}/#{WordleTweet.all.count}. taotal invalids: #{white n_invalids}"
    # before do
    #   order.perform_callbacks
    # end
  end


  desc "Load configuration file for Wordle.."
  task wordle_config: :environment do
    envputs 'Showing WordleConfig YAML: WORDLE_REGEXES'
    envputs WORDLE_REGEXES
    WORDLE_REGEXES.each{ |conf| 
      #envputs "Parsing conf (class: #{conf.class}): #{conf}" 
      envputs "#{conf[:return] rescue :ret} - #{conf[:url] rescue :error}"
      raise "Wrong class should he a hash, not: #{conf.class}" unless conf.is_a?(Hash)
    }
  end

end
