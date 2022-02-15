# Should map to Twitter User Object: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/user
class TwitterUser < ApplicationRecord
    validates_uniqueness_of :twitter_id
    has_many :tweets, counter_cache: true

    # has many wordle_tweets -> through another -> can i do this?
    # FIGATA FUNGE!
    has_many :wordle_tweets, :through => :tweets 

    def url 
#        "http://twitter.com/#{username}"
        "https://twitter.com/intent/user?user_id=#{self.id_str}"
    end
    def url_by_id 
       # https://stackoverflow.com/questions/4132900/url-link-to-twitter-user-with-id-not-name
        #"https://twitter.com/intent/user?user_id=#{twitter_id}"
        "https://twitter.com/intent/user?user_id=#{self.id_str}"
    end

    def username 
        twitter_id
    end
    def ldap
        twitter_id
    end

    def distinct_wordle_types
        # todo remove nil
        self.tweets.map{|t| t.wordle_tweet.wordle_type rescue nil}.select{|x| not x.nil? }.uniq
    end
    
    # number of wordle tweeted
    def polyglotism
        distinct_wordle_types.count
    end

    def average_score
        self.wordle_tweets.average :score
    end

    def accountid
        twitter_id
    end
    def to_stylistic_s(style=:default)
        return to_s if style == :default
        

        case style 
        when :twitter_user 
          # I already know the user! I won't publish it
          #"#{flag} 🏆#{wordle_tweet.score_str} for  #{inc_day} #{excerpt}"
        when :sobenme
          "sobenme"
        when :last10 # probably last 10 have no menaingful avg score or pologlotism..
            "🐦 #{self.twitter_id} 🔄##{tweets.count} 🏆#{tweets.count == 0 ? '-' : average_score} 👅#{polyglotism})"
        when :verbose
          #"((#{style})) [#{wordle_type} #{self.twitter_user}] 🏆#{wordle_tweet.score_str} #{full_text}"
          "🐦 #{self.twitter_id} 🔄##{tweets.count} 🏆#{tweets.count == 0 ? '-' : average_score} 👅#{distinct_wordle_types})"
        else
          # default
          "🐦 #{self.twitter_id} 🔄##{tweets.count} 🏆#{tweets.count == 0 ? '-' : average_score} 👅#{polyglotism})"
#          return to_s
          #"[#{flag} #{self.twitter_user.ldap}] 🏆#{wordle_tweet.score_str} #{excerpt}"    
        end
    end
    def to_s(verbose=false)
        return "TwitterUser @#{self.twitter_id} #{url_by_id}" if verbose        
        "@#{self.twitter_id} [#{tweets.count} tweets]"
    end
end
