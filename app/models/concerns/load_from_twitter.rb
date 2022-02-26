# DHH idea: https://gist.github.com/dhh/1014971

# Riccardo library to parse/call twitter APIs

module LoadFromTwitter
    extend ActiveSupport::Concern


    require 'json'
    require 'socket'
    require 'twitter'

    # included do
    #   default_scope   where(trashed: false)
    #   scope :trashed, where(trashed: true)
    # end

    # def trash
    #   update_attribute :trashed, true
    # end
    #puts green "Including LoadFromTwitter module REMOVEME quando funge"

    # name derives from fact that originally th ecode was in rake db:seed
    # https://github.com/collectiveidea/delayed_job - if you want to always call asynchronously its easy peasy.
    #  handle_asynchronously :call_an_instance_method, :priority => Proc.new {|i| i.how_important }
    # def self.seed_by_calling_twitter_apis(search_key, search_count, opts={})
    #     puts red("not implenented yet 1")
    #     end

    # def seed_by_calling_twitter_apis(search_key, search_count, opts={})
    #     puts red("not implenented yet 1")
    # end
    @@common_header = "[#{white 'DB:SEED'}][#{yellow Rails.env.first(4)}] "
    @@hostname =  Socket.gethostname.split('.')[0] rescue "hostname_error"

    #    TODO: private
    def self.db_seed_puts(str)
        puts "C[#{white :Tweet}][#{yellow Rails.env.first(5)}] #{@@common_header}#{str}"
    end
    def db_seed_puts(str)
        puts "I[#{white :Tweet}][#{yellow Rails.env.first(5)}] #{@@common_header}#{str}"
    end
    def self.invoke_seeding_from_concern(search_key, search_count, opts={})
        puts :todo1
    end

    # invoke_seeding_from_concern() is called firectly by wrapper: `seed_by_calling_twitter_apis`
    def invoke_seeding_from_concern(search_key, search_count, opts={})
        description = opts.fetch :description, "CLASS(ricc): do this asynchronously. Probabluy with> Tweet.delay.seed_by_calling_twitter_apis(...) "
        twittersecret_api_key = opts.fetch :twittersecret_api_key,    ENV['TWITTER_CONSUMER_KEY']
        twittersecret_api_key_secret= opts.fetch :twittersecret_api_key_secret,    ENV['TWITTER_CONSUMER_SECRET']
        debug = opts.fetch :debug, false

        #:bearer_token => ENV["TWITTER_BEARER_TOKEN"],
        db_seed_puts("INSTANCE::invoke_seeding_from_concern(sucks): desc='#{white description}' search_key=#{white search_key}, search_count=#{search_count}")

        client = Twitter::REST::Client.new do |config|
          config.consumer_key        = twittersecret_api_key
          config.consumer_secret     = twittersecret_api_key_secret
        end

        puts "[DEB] invoke_seeding_from_concern() Looking for #{white search_count} tweets matching #{yellow search_key}:" if debug
        return rake_seed_parse_keys_clone_for_single_search(client, search_key, search_count, opts)
    end

def manage_twitter_serialization(tweet, opts={})
    m = tweet
    path = File.expand_path('./tmp/marshal/')
    myhash = [tweet.user.screen_name , tweet.id].join("-")
    puts "[marshal_on_file] Habemus Matchem 2 [pat=#{path}]: '#{tweet.text.gsub("\n"," ")}'"
    File.open("#{path}/dumpv10-#{myhash}.yaml", 'w') { |f| f.write(YAML.dump(m)) }
    File.open("#{path}/dumpv10-#{myhash}.obj", 'wb') { |f| f.write(Marshal.dump(m)) }
    #puts 'DEBUG END AFTER ONE until it works :)'
    #exit 42
end

    # cloned the rake db:seed but this time its single search term - i know its N clients but it was the same before wannit?
def rake_seed_parse_keys_clone_for_single_search(client, search_term, search_count, opts={})
    marshal_on_file = opts.fetch :marshal_on_file, false
    debug = opts.fetch :debug, true
    description = opts.fetch :description, "Descriptio infeliciter non datur"
    source = opts.fetch :source, ""

    error = nil

   # $search_terms.each do |search_term|
      puts "[🐦 API_CALL] Searching for N=#{white search_count} for term '#{azure search_term}'.. Description: '#{white description}'"
      puts azure("😟 I have the presentiment that something iffy might be happening: Lets make sure the $vars from rake db:seed are available also from Runner and other callers :) Lets see: $rake_seed_import_version=#{yellow $rake_seed_import_version}, hostname=#{ @@hostname }")
      n_saved_tweets = 0
      n_unsaved_tweets = 0
      n_saved_users = 0
      n_called_tweets = 0
      # Call Twitter API and iterates over tweets.
      # can return Twitter::Error::TooManyRequests TODO rescue this exception ma per ora va bene cosi'
#      twitter_api_results = [] 
      begin 
        twitter_api_results = client.search(search_term).take(search_count) #rescue []
      rescue Twitter::Error::TooManyRequests 
        twitter_api_results = []
        error = 'known: Twitter::Error::TooManyRequests'
      end
      twitter_api_results.each do |tweet|
#      client.search(search_term).take(search_count).each do |tweet|
        n_called_tweets += 1

        # # consider REMOVING THIS
        # quick_match = WordleTweet.quick_match(tweet.text)
        # puts "QM=#{quick_match.id rescue :boh}" if debug
        # # if quick match is not there, I skip - but first i write down why...
        # puts "Failed match for tweet: #{white(tweet.text) rescue :err}" if debug and (not quick_match)
        # next unless quick_match


        # Tweet matches :)
        manage_twitter_serialization if marshal_on_file
        wordle_type = WordleTweet.extended_wordle_match_type(tweet.text)
        if not wordle_type.nil?
          #puts "[DEB] Found [#{ wordle_type}] #{short_twitter_username(tweet.user)}:\t'#{( tweet.text.split("\n")[0] )}'" # text[0,30]
          u = tweet.user
          #print "[deb] 1. Creating Twitter user: #{ u.screen_name} (#{u.name}, #{u.location}).."
          tu = TwitterUser.create(
              twitter_id: u.screen_name,
              location:   u.location,
              name:       u.name,
              # added after 1500 were already added :)
              description: u.description,
              id_str:      u.id.to_s, #id_str doesnt work
              # eg @palladius => 17310864
              # consider adding:
              # *    :profile_image_url: http://pbs.twimg.com/profile_images/2448864122/jicix70clvqqeazgdxh3_normal.jpeg
              # *    :created_at: Tue Nov 11 14:48:00 +0000 2008

          )
          saved = tu.save
          # TODO(ricc): update Existing with new descriptions even if it already exists
          #puts "1. Created TwitterUser: #{tu} id=#{tu.id rescue :noid}" if saved
          n_saved_users += 1 if saved

          if $check_already_exists
            already_exists = Tweet.find_by_twitter_id(tweet.id)
            if already_exists
#                puts "- [CACHE] Already exists TODO update if needed: [#{tu}] '#{already_exists.excerpt rescue :noExcerpt}' (import v#{already_exists.import_version})" if debug
                puts "- [CACHE] Already exists (v#{yellow already_exists.import_version}): [#{tu}] '#{already_exists.excerpt(50) rescue :noExcerpt}' " if debug
                print 'c' if ($rake_seed_import_version != already_exists.import_version)
            else  #
                print "NEW" if debug
            end
            next if already_exists
          end
          #print "2. [#{tweet.created_at}] Creating Tweet info based on existence of twitter_id :)"
          hash = {
              app_ver: APP_VERSION,
              search_term: search_term,

              # POLYMOPRH_BEGIN polymorphically adding this
              twitter_retweeted:  (tweet.retweeted rescue nil),
              twitter_lang:  (tweet.lang rescue nil),
              twitter_retweet_count:  (tweet.retweet_count rescue nil),
              # POLYMOPRH_END
              code_description: description,
              source: source , # rescue nil

              hostname: @@hostname.split('.')[0]
          } # I know - but it helps with commas :)
          rails_tweet = Tweet.create(
              twitter_user: TwitterUser.find_by_twitter_id(tweet.user.screen_name) ,
              full_text: tweet.text,
              # 2022-02-06 updated this
              #created_at: tweet.created_at,
  #              id: tweet.id,
              twitter_id:  tweet.id,
              twitter_created_at: tweet.created_at,
              import_version: $rake_seed_import_version,
              import_notes: "Moved to LoadFromTwitter and to jonb on its own.",
              internal_stuff: "search_term='#{search_term rescue :unknown}'",
              # polymoprhic stuff in case new stuff comes to my mind..
              json_stuff: hash.to_json,
          )
          saved_tweet = rails_tweet.save
          if saved_tweet
            puts "- Non-Trivial #{yellow rails_tweet.wordle_type} Tweet saved: #{rails_tweet.id} from #{rails_tweet.to_s}"  if (
                (rails_tweet.wordle_type != "wordle_en") or debug)
            n_saved_tweets += 1
          else
            # single error here.
            n_unsaved_tweets += 1
            print 'e' # putchar ERROR
            puts yellow(rails_tweet.to_s(true))  if debug
            puts red(rails_tweet.errors.full_messages)  if debug
            end
        end
        #client.update("@#{tweet.user} Hey I love Ruby too, what are your favorite blogs? :)")
      end
      puts "  - #{ yellow n_saved_tweets} saved tweets / #{white n_unsaved_tweets} unsaved; #{yellow n_saved_users} new users. Tweets returned by API: #{green n_called_tweets}"
      return {
          :saved_tweets => n_saved_tweets,
          :unsaved_tweets => n_unsaved_tweets,
          :saved_users => n_saved_users,
          :called_tweets => n_called_tweets,
          :search_term => search_term,
          :source => source,
          :error => error,
      }
  end

  def to_safe_s()
    self.to_s rescue "#{self.class}.to_s() exception: #{$!}"
  end

  end
