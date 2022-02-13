class RemoveCommentsAndPosts < ActiveRecord::Migration[7.0]
  def change
    drop_table :posts
    drop_table :comments
    # remove this foreign key:
    #   add_foreign_key "comments", "articles"
    # docs: https://stackoverflow.com/questions/23718292/foreigner-remove-foreign-key
#    remove_foreign_key :comments, :articles
    #remove_foreign_key :articles, :comments
  end
end
