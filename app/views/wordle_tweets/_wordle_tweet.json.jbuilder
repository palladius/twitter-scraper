json.extract! wordle_tweet, :id, :wordle_type, :tweet_id, :score, :wordle_date, :wordle_incremental_day, :import_version, :import_notes, :created_at, :updated_at
json.url wordle_tweet_url(wordle_tweet, format: :json)
