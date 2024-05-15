class CreateFriendships < ActiveRecord::Migration[6.1]
  def change
    create_table :friendships, force: :cascade do |t|
      t.references :member, null: false, foreign_key: true
      t.references :friend, null: false, foreign_key: true

      t.timestamps
    end

    add_index :friendships, [:member_id, :friend_id], unique: true
  end
end
