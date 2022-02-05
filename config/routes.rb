Rails.application.routes.draw do
  resources :wordle_tweets
  resources :tweets
  resources :twitter_users
  resources :comments
  resources :posts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
