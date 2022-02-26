Rails.application.routes.draw do
  resources :wordle_games
  resources :wordle_tweets
  resources :tweets
  resources :twitter_users
  resources :comments
  resources :posts

  # creato a manhouse da ricc..

  get "/games/actions/seed_all", to: "games#action_seed_all"
  get "/games/actions/seed_by_search_term", to: "games#action_seed_by_search_term"
  #  resources :games

  get "/articles", to: "articles#index"
  get "/articles/stats", to: "articles#stats"

  %w{ stats wordle about dialects test }.each{|article_route| 
    # correct POLA path
    get "/articles/#{article_route}", to: "articles##{article_route}"
    # nie to have path =  ma poi mi incasino!
    #get "/#{article_route}", to: "articles##{article_route}"
  }

  # regenerate
  get '/tweets/:id/regenerate', to: 'tweets#regenerate'

  #get "/stats", to: "articles#stats"
  #get "/wordle", to: "articles#wordle"
  #get "/about", to: "articles#about"
  #get "/dialects", to: "articles#dialects"
  
  #bin/rails generate controller Articles index stats about wordle --skip-routes

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # -  root "articles#index"
  root "articles#about"
end
