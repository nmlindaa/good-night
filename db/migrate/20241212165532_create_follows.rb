class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows, id: :uuid do |t|
      t.uuid :follower_id
      t.uuid :followed_id
      t.timestamps
    end
    add_foreign_key :follows, :users, column: :follower_id
    add_foreign_key :follows, :users, column: :followed_id
    add_index :follows, [:follower_id, :followed_id], unique: true
  end
end
