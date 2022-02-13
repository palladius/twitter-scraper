class RemoveCommentsAndPosts < ActiveRecord::Migration[7.0]
  def change
    # creato solo per ripulire lo schema - li avevo gia tolti a manhouse...
    #drop_table :posts
    #drop_table :comments
  end
end
