class AddBoringStuffToTwitter < ActiveRecord::Migration[7.0]
  def change
    add_column :tweets, :import_version, :string
    add_column :tweets, :import_notes, :string
    add_column :tweets, :internal_stuff, :string
    # polymoprhic stuff in case new stuff comes to my mind..
    add_column :tweets, :json_stuff, :text
    # the unique tweet id which should be UNIQUE :)
    add_column :tweets, :twitter_id, :string
    add_column :tweets, :twitter_created_at, :timestamp
    
  end
end
