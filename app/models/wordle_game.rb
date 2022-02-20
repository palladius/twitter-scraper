
#   create_table "wordle_games", force: :cascade do |t|
#     t.string "wordle_incremental_day"
#     t.string "wordle_type"
#     t.string "solution"
#     t.date "date"
#     t.text "json_stuff"
#     t.text "notes"
#     t.float "cache_average_score"
#     t.integer "cache_tweets_count"
#     t.string "import_version"
#     t.text "import_notes"
#     t.datetime "created_at", precision: 6, null: false
#     t.datetime "updated_at", precision: 6, null: false
#   end


class WordleGame < ApplicationRecord
   # belongs_to :tweet
   # validates_presence_of :score
   # validates_presence_of :wordle_type # added on 18feb20
    has_many :tweets
    validates_presence_of :wordle_type, :wordle_incremental_day
    validates :wordle_type, uniqueness: { scope: :wordle_incremental_day }
#    belongs_to :wordle_type


    def url
        "TODO(ricc): will find from my yamls..." 
    end


    def  safe_solution
    solution.to_s.length
    end

    # calculated, could have some hits.
    def name 
        wid = wordle_incremental_day.gsub "int/","" rescue :err
        "#{wordle_type}::#{wid}"
    end

    # todo: if old you poersist its data...
    def old?
        false
    end

    def average_score
        #WordleGame.first.wordle_tweets.map{|wt| wt.score}
  #      arr.inject{ |sum, el| sum + el }.to_f / arr.size
        WordleTweet.averagization(
            #WordleGame.first.wordle_tweets.map{|wt| wt.score}
            wordle_tweets.map{|wt| wt.score}
        )
    end

    def to_s(verbose=false)
        name
    end

    def wordle_tweets 
        WordleTweet.where(
            :wordle_type => wordle_type, 
            :wordle_incremental_day => wordle_incremental_day
        )
    end

    def min_date 
        # ok i wanna be dry, but u never know how i reimplement it :)
        # WordleTweet.where(
        #     :wordle_type => wordle_type, 
        #     :wordle_incremental_day => wordle_incremental_day
        # )
        wordle_tweets.map{|x| x.tweet.twitter_created_at}.min.to_date
    end
    def max_date 
        # ok i wanna be dry, but u never know how i reimplement it :)
        # WordleTweet.where(
        #     :wordle_type => wordle_type, 
        #     :wordle_incremental_day => wordle_incremental_day
        # )
        wordle_tweets.map{|x| x.tweet.twitter_created_at}.max.to_date
    end


        # create_table "tweets", force: :cascade do |t|
        #     t.bigint "twitter_user_id", null: false
        #     t.string "full_text"
        #     t.datetime "created_at", precision: 6, null: false
        #     t.datetime "updated_at", precision: 6, null: false
        #     t.string "import_version"
        #     t.string "import_notes"
        #     t.string "internal_stuff"
        #     t.text "json_stuff"
        #     t.string "twitter_id"
        #     t.datetime "twitter_created_at"
        #     t.index ["twitter_user_id"], name: "index_tweets_on_twitter_user_id"
        #   end
    def self.create_from_tweet_if_necessary(tweet)
        print "create_from_tweet_if_necessary: START"
        import_version = "0.1"
        begin 
            json_stuff = {}
            json_stuff[:creator_tweet_id] = tweet.id 
            json_stuff[:creator_twitter_id] = tweet.twitter_id 

            wg = WordleGame.new 
            wg.wordle_type = tweet.wordle_type 
            wg.wordle_incremental_day = tweet.wordle_incremental_day
            wg.json_stuff = json_stuff
            wg.import_version = import_version 
            # day, solution -> nil
            wg.save
            return wg
        rescue Exception 
            puts red("WordleGame::create_from_tweet_if_necessary(#{tweet}) Some error: #{$!}")
        end
    end

end
