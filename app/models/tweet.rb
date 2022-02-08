# ricc: maps to Twitter TWEET object: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet

class Tweet < ApplicationRecord
  belongs_to :twitter_user
  #class WordleTweet < ApplicationRecord
  #  belongs_to :tweet
  has_one :wordle_tweet

  #  validates_uniqueness_of : #  : references 
  validates :full_text, uniqueness: { scope: :twitter_user }

  # how long ago was the tweet created from when its parsed by ricc :)
  def freshness
    (created_at - twitter_created_at) rescue nil
  end

  def excerpt(n_chars = 25)
    # copied from https://apidock.com/rails/v5.2.3/ActionView/Helpers/TextHelper/excerpt
    (self.full_text[0, n_chars].gsub("\n"," ") rescue "ERR_no_fuLltext") + ".."
  end

  def length
    full_text.length
  end

  def wordle_type
    wordle_tweet.wordle_type rescue :boh
  end
  alias :type :wordle_type

  def stats 
    wordle_tweet.stats
  end 

  def url
    # as per https://stackoverflow.com/questions/23008129/how-to-construct-a-url-from-a-twitter-direct-message-id
    # eg https://twitter.com/palladius/status/1490373849841557509
    "https://twitter.com/#{twitter_user.accountid}/status/#{self.id}"
  end

  after_create do |tweet|
    #puts "Tweet::after_create created. Now creating Wordle brother."
    WordleTweet.create_from_tweet(tweet)
  end
  
  def to_s
    "[#{wordle_type} #{self.twitter_user}] #{excerpt}"
  end

end
