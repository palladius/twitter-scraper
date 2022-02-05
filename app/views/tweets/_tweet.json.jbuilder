json.extract! tweet, :id, :twitter_user_id, :full_text, :created_at, :updated_at
json.url tweet_url(tweet, format: :json)
