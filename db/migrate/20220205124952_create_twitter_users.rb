class CreateTwitterUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :twitter_users do |t|
      t.string :twitter_id
      t.string :name
      t.string :location

      t.timestamps
    end
  end
end
