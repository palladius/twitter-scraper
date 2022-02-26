class GamesController < ApplicationController



    # call an action from controller to be then called by GCF
    # https://stackoverflow.com/questions/5212351/can-i-somehow-execute-my-db-seeds-rb-file-from-my-rails-app
    # curl http://localhost:3000/games/actions/seed_all
    def action_seed_all
        @action = :seed_all
        # calls rake db:seed so eberything works perfectly.
        @results = Rails.application.load_seed
        @description = 'Seeding ALL search words. This might take some time..'
        flash[:error] = "Will take some time..."
    end

    # curl http://localhost:3000/games/actions/seed_by_search_term
    def action_seed_by_search_term
        # calls manually the serach of a word: had to redefine a lot of $global variables in rake db:seed file, which is GOOD so now the
        # code can work without those dependencies and we can slowly remove them
        # We just neeed to map/document correctly ALL ENV vars which become here QueryStrings :)

        @n_tweets = (params.fetch :n_tweets, '10').to_i
        #@TODO
        @background = (params.fetch :background, false).to_s.downcase == "true" # to_bool
        @search_term = params.fetch :search_term, '@wordlefr'
        @debug = (params.fetch 'debug', false).to_s.downcase == "true" # to bool
        
        @action = :seed_by_search_term

        flash[:error] = "Some error in GamesController"
        flash[:warn] = "Some WARN in GamesController"

        @description = "[seed_by_search_term] Looking for #{@n_tweets} tweets matching #Wordle hashtag: ;;#{ @search_term};; [DEB=#{ @debug}]"

        ret = Tweet.seed_by_calling_twitter_apis(
            @search_term,  
            @n_tweets, 
            {
              :description => 'DIRECT (non-delayed) call from GamesController',
              :source => 'GamesController',
              :debug => @debug ,
            }
        )
        @results = ret 
        puts "GamesController:API call returned ret=#{ret}"
    end

 end 
