class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.references :twitter_user, null: false, foreign_key: true
      t.string :full_text

      t.timestamps
    end
  end
end
