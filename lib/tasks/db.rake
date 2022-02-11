# created with: rails g task db sbirciatina popola

def envputs(s)
  puts "[#{Rails.env}] #{s}"
end

def write_entity_cardinalities()
  envputs "ENV:     #{Rails.env}"
  envputs "Tweets:  #{Tweet.all.count}"
  envputs "Users:   #{TwitterUser.all.count}"
  envputs "WTweets: #{WordleTweet.all.count}"
end

namespace :db do
  desc "take a quick look at whats inside :)"
  task sbirciatina: :environment do

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

  desc "TODO"
  task popola: :environment do
  end

end
