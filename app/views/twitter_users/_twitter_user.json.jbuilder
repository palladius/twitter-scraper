json.extract! twitter_user, :id, :twitter_id, :name, :location, :created_at, :updated_at
json.url twitter_user_url(twitter_user, format: :json)
