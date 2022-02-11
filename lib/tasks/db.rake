# created with: rails g task db sbirciatina popola

def envputs(s)
  puts "[#{Rails.env}] #{s}"
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

    write_entity_cardinalities
    envputs 'Calling post-cretion callbacks..'
    Tweet.all.each {|t| t._run_create_callbacks}
    write_entity_cardinalities

    # Types: WordleTweet.group(:wordle_type).count

    tweet_types = WordleTweet.group(:wordle_type).count
    envputs "Twitter types: #{tweet_types}"
    envputs " == WordleTweets =="
    WordleTweet.all.each { |wt|
      envputs "+ [valid=#{wt.valid?}] #{wt}"
    }
    # before do
    #   order.perform_callbacks
    # end
  end

end
