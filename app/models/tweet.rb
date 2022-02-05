# ricc: maps to Twitter TWEET object: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet

class Tweet < ApplicationRecord
  belongs_to :twitter_user

  #  validates_uniqueness_of : #  : references 
  validates :full_text, uniqueness: { scope: :twitter_user }

  after_create do |tweet|
    puts "Tweet::after_create created. Now creating Wordle brother."
    WordleTweet.create_from_tweet(tweet)
  end
  
  def to_s
    "[#{self.twitter_user}] #{full_text}"
  end

end
