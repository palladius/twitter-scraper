Rails.application.routes.draw do
  resources :wordle_tweets
  resources :tweets
  resources :twitter_users
  resources :comments
  resources :posts

  get "/articles", to: "articles#index"
  get "/articles/stats", to: "articles#stats"
  get "/stats", to: "articles#stats"
  get "/wordle", to: "articles#wordle"
  get "/about", to: "articles#about"
  #bin/rails generate controller Articles index stats about wordle --skip-routes

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "articles#index"
end
