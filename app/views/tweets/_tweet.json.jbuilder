json.extract! tweet, :id, :twitter_user_id, :full_text, :created_at, :updated_at, :import_version, :import_notes, :internal_stuff, :json_stuff, :twitter_id, :twitter_created_at
json.url tweet_url(tweet, format: :json)
