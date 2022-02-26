class GamesController < ApplicationController



    # call an action from controller to be then called by GCF
    # https://stackoverflow.com/questions/5212351/can-i-somehow-execute-my-db-seeds-rb-file-from-my-rails-app
    # curl http://localhost:3000/games/actions/seed_all
    def action_seed_all
        @action = :seed_all
        @results = :TODOSEED # Rails.application.load_seed
        @description = 'Seeding ALL search words. This might take some time..'
        flash[:error] = "Will take some time..."
    end

    # curl http://localhost:3000/games/actions/seed_by_search_term
    def action_seed_by_search_term
        @n_tweets = params.fetch :n, 10
        #@TODO
        @background = (params.fetch :background, false).to_s.downcase == "true" # to_bool
        @search_term = params.fetch :search_term, '@wordlefr'
        @debug = (params.fetch 'debug', false).to_s.downcase == "true" # to bool
        
        @action = :seed_by_search_term

        flash[:error] = "Some error in GamesController"
        flash[:warn] = "Some WARN in GamesController"

        @description = "[seed_by_search_term] Looking for #{@n_tweets} tweets matching #Wordle hashtag: ;;#{ @search_term};; [DEB=#{ @debug}]"

        # intermediate_search_term = ENV.fetch 'SEARCH_ONLY_FOR', nil 
        # search_terms = intermediate_search_term.nil? ?
        #   $search_terms :               # Global thingy
        #   [ intermediate_search_term]   # local if you provide $SEARCH_ONLY_FOR
        # puts "Searching for these keywords: #{azure search_terms.join(', ')}"
        # search_terms.each do |search_term|
        ret = Tweet.seed_by_calling_twitter_apis(
            @search_term,  
            @n_tweets, 
            {
              :description => 'DIRECT (non-delayed) call from GamesController',
              :debug => @debug ,
            }
        )
        @results = ret 
        puts "GamesController:API call returned ret=#{ret}"
    end

 end 
