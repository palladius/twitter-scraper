# Should map to Twitter User Object: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
class TwitterUser < ApplicationRecord
    validates_uniqueness_of :twitter_id
    has_many :tweets, counter_cache: true

    def url 
        "http://twitter.com/#{username}"
    end
    def url_by_id 
       # https://stackoverflow.com/questions/4132900/url-link-to-twitter-user-with-id-not-name
        "https://twitter.com/intent/user?user_id=#{twitter_id}"
    end

    def distinct_wordle_types
        # todo remove nil
        self.tweets.map{|t| t.wordle_tweet.wordle_type rescue nil}.select{|x| not x.nil? }.uniq
    end
    
    # number of wordle tweeted
    def polyglotism
        distinct_wordle_types.count
    end

    def accountid
        twitter_id
    end
    def to_s(verbose=false)
        return "TwitterUser @#{self.twitter_id} #{url_by_id}" if verbose
        
        "@#{self.twitter_id} [#{tweets.count} tweets]"
    end
end
