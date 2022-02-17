# created with: rails g task db sbirciatina popola

def envputs(s)  puts "[#{Rails.env}] #{s}" end



def write_entity_cardinalities()
  t0 = Time.now
  envputs "ENV:     #{Rails.env}     BEGIN=#{t0}"
  envputs "DB_ADAPTER:     #{Rails.configuration.database_configuration[Rails.env]["adapter"]}"
  envputs "DB_CONFIG (secret!):     #{Rails.configuration.database_configuration[Rails.env]}"
  envputs "DB_URL (secret!):     #{Rails.configuration.database_configuration[Rails.env]["url"] rescue :missing}"
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

  def populate_in_test_old_vs_new(bool, debug=false)
    puts ''
    description = bool ? 
      "New Scalable (yet buggy): regex doesnt seem to work AT ALL dammit but code looks a bijou" :
      "Same old same old. Super scheggia, doesnt fail a test, but more and moreencumbring and difficult to test on long run"
    envputs(white("== populate_in_test(#{azure(description)}) =="))
    #write_entity_cardinalities
    #envputs 'Calling post-creation callbacks (which doesnt happen by defaault with TEST fixtures for efficiency reasons)..'
    #Tweet.all.each {|t| t._run_create_callbacks}
    #envputs yellow("TODO ricc change callback with create_from_tweet(tweet, opts cangiante)")
    Tweet.all.each {|t| 
      WordleTweet.create_from_tweet(t, :try_new => bool) 
      #t._run_create_callbacks}
    #
    }
    # Types: WordleTweet.group(:wordle_type).count

    tweet_types = WordleTweet.group(:wordle_type).count
    envputs "Twitter types: #{white tweet_types}" if debug
    envputs "Acceptable types: #{WordleTweet.acceptable_types}" if debug 
    
    envputs " == WordleTweets =="
    WordleTweet.all.each { |wt|
      envputs "+ [#{wt.valid? ? :OK : :INVALID }] #{wt.flag} T='#{yellow wt.wordle_type}' day=#{white wt.parse_incrementalday_from_text} expected_is=#{yellow(wt.tweet.internal_stuff) rescue :nada}" unless wt.valid?
    }
    puts("WTTypes: #{ WordleTweet.all.map{|wt| wt.wordle_type}.join(", ") }")  if debug 
    puts("WTFlags: #{WordleTweet.all.map{|wt| wt.flag}.join(" ")}")
    envputs " == WordleTweets ERRORS [new=#{bool}]=="
    n_errors = 0
    n_invalids = 0
    WordleTweet.all.each { |wt|
      #bad_type = wt.wordle_type.to_s.in? ['', 'unknown_v2']
      unless wt.wordle_type.in?(WordleTweet.acceptable_types)
        envputs "[#{red :BAD1}] #{wt.flag} type='#{yellow  wt.wordle_type}' score=#{yellow wt.score} day='#{yellow wt.parse_incrementalday_from_text}' MagicInfo='#{yellow(wt.tweet.internal_stuff) rescue :nada}'"
        # make it printable: .gsub(/[^[:print:]]/,'.')
        envputs "[#{red :BAD2}] TXT='#{white wt.tweet.printable_text }'"
        expected = wt.tweet.internal_stuff.match(/should be ([a-z_]+) \/\//)[1] rescue :error_parsing
        envputs "[#{red :BAD3}] Should be #{green expected} but its '#{red wt.wordle_type }'"
        n_errors += 1
        wt.validate
        n_invalids += 1 unless wt.valid?
      end
    }
    puts "END. Total Errors: #{yellow n_errors}/#{white WordleTweet.all.count}. Total invalids: #{azure n_invalids}."
    puts red("Now go to the Model and fix it mofo! (or maybe if its new remember also to ad to array f valid shtuff)") if n_errors>0
  end 

  desc "popola in test"
  task popola_test: :environment do
    raise "Funge solo in TEST!!" unless Rails.env == "test"
    envputs 'TODO(ricc): move to proper rake tests'
    populate_in_test_old_vs_new false 
    populate_in_test_old_vs_new true 
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
