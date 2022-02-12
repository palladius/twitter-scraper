# followed this: https://stackoverflow.com/questions/6834175/migrations-change-column-from-integer-to-string
# problem is, some sites dont have an increasing INTEGER unfortunately :/
# I'm also thinking of making it smarter.
class ChangeWordleIncrementalDayToBeStringInWordleTweets < ActiveRecord::Migration[7.0]
  def change
    change_column :wordle_tweets, :wordle_incremental_day, :string
  end
end
