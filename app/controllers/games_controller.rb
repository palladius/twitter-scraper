class GamesController < ApplicationController



    # # call an action from controller to be then called by GCF
    # # https://stackoverflow.com/questions/5212351/can-i-somehow-execute-my-db-seeds-rb-file-from-my-rails-app
    # # curl http://localhost:3000/games/actions/seed_all
    def action_seed_all
        @action = :seed_all
        # calls rake db:seed so eberything works perfectly.
        @results = Rails.application.load_seed
        @description = 'Seeding ALL search words. This might take some time.. DEPRECATED use /actions/seed_by_search_term instead'
        flash[:error] = "Will take some time..."
        flash.now[:notice] = "[TEST] We have exactly #{42} books available."
    end

    # curl http://localhost:3000/games/actions/seed_by_search_term
    def action_seed_by_search_term
        # calls manually the serach of a word: had to redefine a lot of $global variables in rake db:seed file, which is GOOD so now the
        # code can work without those dependencies and we can slowly remove them
        # We just neeed to map/document correctly ALL ENV vars which become here QueryStrings :)

        @n_tweets = (params.fetch :n_tweets, '10').to_i
        #@TODO
        @search_term = (params.fetch :search_term, '@wordlefr').gsub('hashtag','#')
        @background = (params.fetch :background, false).to_s.downcase == "true" # to_bool
        @dryrun = (params.fetch :dryrun, false).to_s.downcase == "true" # to_bool
        @debug = (params.fetch 'debug', false).to_s.downcase == "true" # to bool
        @caller_id = params.fetch 'caller_id', 'unknown_caller_id' # in case you want to say something from the internet, like caller details
        @marshal_on_file = (params.fetch 'marshal_on_file', :false).to_s.downcase == "true"
        @action = :seed_by_search_term
        @delay = (params.fetch :delay, false).to_s.downcase == "true" # to_bool

        #flash[:error] = "Some error in GamesController"
        flash[:warn] = "marshal_on_file is enabled. Note that on docker this is useless :) Only enable it on your computer.. AM_I_ON_DOCKER=#{AM_I_ON_DOCKER}" if @marshal_on_file
        #flash.now[:notice] = "[TEST] We have exactly #{42} books available."

        @description = "[seed_by_search_term] Looking for #{@n_tweets} tweets matching #Wordle hashtag: ;;#{ @search_term};; [DEB=#{ @debug}, @caller_id=#{@caller_id}] DEPRECATED use /actions/seed_by_search_term instead"

        opts = {
            :source => "GamesController::#{@caller_id}",
            :debug => @debug ,
            :marshal_on_file => @marshal_on_file,
        }
        if @delay
            # run delayed so I dont know what it returns...
            opts[:description] = 'DELAYED call from GamesController'
            opts[:source] = "[DELAY]" + opts[:source]
            ret = Tweet.seed_by_calling_twitter_apis(@search_term, @n_tweets, opts)
        else
            opts[:description] = 'DIRECT (non-delayed) call from GamesController'
            opts[:source] = "[DIRECT]" + opts[:source]
            ret = Tweet.seed_by_calling_twitter_apis(@search_term, @n_tweets, opts)
        end
        @results = ret 
        puts "GamesController:API call returned ret=#{ret}"
    end

 end 
