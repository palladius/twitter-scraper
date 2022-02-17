# ricc: maps to Twitter TWEET object: https://developer.twitter.com/en/docs/twitter-api/v1/data-dictionary/object-model/tweet

# create_table "tweets", force: :cascade do |t|
#   t.integer "twitter_user_id", null: false
#   t.string "full_text"
#   t.datetime "created_at", precision: 6, null: false
#   t.datetime "updated_at", precision: 6, null: false
#   t.string "import_version"
#   t.string "import_notes"
#   t.string "internal_stuff"
#   t.text "json_stuff"
#   t.string "twitter_id"
#   t.datetime "twitter_created_at"
#   t.index ["twitter_user_id"], name: "index_tweets_on_twitter_user_id"
# end

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

  # 25 is just enough to get le mot cropped by 1 :) 
  # "[🇫🇷 GoncaloRamos17] 🏆5 Le Mot (@WordleFR) #36 5/"
  # hence 28 :)
  def excerpt(n_chars = 28)
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
    wt_stats = {}
    wt_stats[:wordle_tweet] = wordle_tweet.stats rescue {:error => "No wordle_tweet apparently"}
    wt_stats[:tweet_valid] = valid?
    wt_stats
  end 

  # borrowed the second part from SO: https://stackoverflow.com/questions/16530038/how-to-remove-non-printable-invisible-characters-in-ruby
  def printable_text
    #"[PrinTbl]" + 
    full_text.gsub("\n",'').gsub(/[^[:print:]]/,'.').gsub(/\s+/, ' ')
  end

  def url
    # as per https://stackoverflow.com/questions/23008129/how-to-construct-a-url-from-a-twitter-direct-message-id
    # eg https://twitter.com/palladius/status/1490373849841557509
    "https://twitter.com/#{twitter_user.accountid}/status/#{self.id}"
  end

  # https://stackoverflow.com/questions/7690697/object-doesnt-support-inspect
  after_create do |tweet|
    #puts "Tweet::after_create created. Now creating Wordle brother."
    WordleTweet.create_from_tweet(tweet)
  end

  def flag 
    self.wordle_tweet.flag rescue nil
  end

  def created_str(which_part='')
    return twitter_created_at.strftime("%F") if which_part == 'day'
    twitter_created_at.strftime("%F %T") rescue :nil
  end

  def wordle_incremental_day
    wordle_tweet.wordle_incremental_day rescue nil
  end
  def score_str
    wordle_tweet.score_str rescue nil
  end
  
  def to_s(style=:generic)
    # depending on conbtext i show differetn stuff
    inc_day = (wordle_incremental_day.match?('int/\d+') rescue false) ? 
      "##{wordle_incremental_day.split('/')[1]}" : 
      wordle_incremental_day
    case style 
      when :twitter_user 
        # I already know the user! I won't publish it
        "#{flag} 🏆#{score_str} for  #{inc_day} #{excerpt}"
      when :sobenme
        "sobenme"
      when :last10 # very small
        "#{flag} #{inc_day} 🏆 #{score_str}/6 🐦 #{self.twitter_user.ldap} "
      when :verbose
        "((#{style})) [#{wordle_type} #{self.twitter_user}] 🏆#{score_str} #{full_text}"
      else
        # default
        "[#{flag} #{self.twitter_user.ldap}] 🏆#{score_str} #{excerpt}"    
      #  "[#{wordle_type} #{self.twitter_user}] 🏆#{wordle_tweet.score} #{excerpt}"
      #  "[#{wordle_type} #{self.twitter_user}] 🏆 #{excerpt}"
      end
  end

end
