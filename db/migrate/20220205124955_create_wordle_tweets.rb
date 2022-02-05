class CreateWordleTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :wordle_tweets do |t|
      t.string :wordle_type
      t.references :tweet, null: false, foreign_key: true
      t.integer :score
      t.date :wordle_date
      t.integer :wordle_incremental_day

      t.timestamps
    end
  end
end
