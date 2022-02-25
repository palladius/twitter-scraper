
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
    validates_presence_of :wordle_type, :wordle_incremental_day # , on: :create
    validates :wordle_type, uniqueness: { scope: :wordle_incremental_day } #, on: :create
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

    # it works!!! Note only first time i call memoized_flag it executes a query!
=begin
irb(main):001:0> wg = WordleGame.first
   (0.7ms)  SELECT sqlite_version(*)
  WordleGame Load (0.1ms)  SELECT "wordle_games".* FROM "wordle_games" ORDER BY "wordle_games"."id" ASC LIMIT ?  [["LIMIT", 1]]                       
irb(main):002:0> wg.memoized_flag
  WordleTweet Load (2.1ms)  SELECT "wordle_tweets".* FROM "wordle_tweets" WHERE "wordle_tweets"."wordle_type" = ? AND "wordle_tweets"."wordle_incremental_day" = ? ORDER BY "wordle_tweets"."id" ASC LIMIT ?  [["wordle_type", "wordle_br"], ["wordle_incremental_day", "int/51"], ["LIMIT", 1]]
=> "🇧🇷"                                                                    
irb(main):003:0> wg.memoized_flag
=> "🇧🇷"
irb(main):004:0> wg.memoized_flag
=> "🇧🇷"    
    See also multi-line memoization here: https://www.justinweiss.com/articles/4-simple-memoization-patterns-in-ruby-and-one-gem/
=end
    def memoized_flag 
        #        @work_has_no_comments ||= comments.count < 1
        @flag ||= self.wordle_tweets.first.flag
        return @flag
    end

    # TODO cache
    def name_with_flag
        "#{memoized_flag}#{name}"
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

    # TODO memoize
    def min_date 
        # ok i wanna be dry, but u never know how i reimplement it :)
        # WordleTweet.where(
        #     :wordle_type => wordle_type, 
        #     :wordle_incremental_day => wordle_incremental_day
        # )
        #wordle_tweets.map{|x| x.tweet.twitter_created_at}.min.to_date
        puts(red "This is WRONG TODO(ricc): calculate correctly in optized way.")
        wordle_tweets.first.tweet.twitter_created_at.to_date       
#        nil
    end
    def max_date 
        # ok i wanna be dry, but u never know how i reimplement it :)
        # WordleTweet.where(
        #     :wordle_type => wordle_type, 
        #     :wordle_incremental_day => wordle_incremental_day
        # )
        # inefficiente!!!
        # memoize
        #@max_date ||= wordle_tweets.map{|x| x.tweet.twitter_created_at}.max.to_date
        #return @max_date
#        return nil
        puts(red "This is WRONG TODO(ricc): calculate correctly in optized way.")
        wordle_tweets.first.tweet.twitter_created_at.to_date       

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
    def self.create_from_tweet_if_necessary(tweet, opts={})
        debug = opts.fetch :debug, false

        print "DEB WordleGame::create_from_tweet_if_necessary(): START" if debug
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
