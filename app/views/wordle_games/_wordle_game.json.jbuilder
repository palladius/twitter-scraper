json.extract! wordle_game, :id, :wordle_incremental_day, :wordle_type, :solution, :date, :json_stuff, :notes, :cache_average_score, :cache_tweets_count, :import_version, :import_notes, :created_at, :updated_at
json.url wordle_game_url(wordle_game, format: :json)
