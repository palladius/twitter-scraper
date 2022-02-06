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
    created_at - twitter_created_at rescue nil
  end

  def url
    # TBD https://stackoverflow.com/questions/23008129/how-to-construct-a-url-from-a-twitter-direct-message-id
    # eg https://twitter.com/palladius/status/1490373849841557509
    "https://twitter.com/{accountid}/status/{tweetid}"
  end

  after_create do |tweet|
    puts "Tweet::after_create created. Now creating Wordle brother."
    WordleTweet.create_from_tweet(tweet)
  end
  
  def to_s
    "[#{self.twitter_user}] #{full_text}"
  end

end
