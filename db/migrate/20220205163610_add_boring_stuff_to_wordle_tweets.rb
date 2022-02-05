class AddBoringStuffToWordleTweets < ActiveRecord::Migration[7.0]
  def change
    add_column :wordle_tweets, :import_version, :string
    add_column :wordle_tweets, :import_notes, :string
    add_column :wordle_tweets, :internal_stuff, :string
    add_column :wordle_tweets, :max_tries, :integer # default 6
    add_column :twitter_users, :id_str, :string     # Twitter Integer Id, but keep as string as safer :) 
    add_column :twitter_users, :description, :string     # Twitter description, "The user-defined UTF-8 string describing their account"
  end
end
