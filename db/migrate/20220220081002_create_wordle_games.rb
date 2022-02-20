class CreateWordleGames < ActiveRecord::Migration[7.0]
  def change
    create_table :wordle_games do |t|
      t.string :wordle_incremental_day
      t.string :wordle_type
      t.string :solution
      t.date :date
      t.text :json_stuff
      t.text :notes
      t.float :cache_average_score
      t.integer :cache_tweets_count
      t.string :import_version
      t.text :import_notes

      t.timestamps
    end
  end
end
