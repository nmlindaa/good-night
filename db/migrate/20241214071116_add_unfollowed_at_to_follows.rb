class AddUnfollowedAtToFollows < ActiveRecord::Migration[8.0]
  def change
    add_column :follows, :unfollowed_at, :datetime
    add_index :follows, :unfollowed_at
  end
end
