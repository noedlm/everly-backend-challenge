class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :url, null: false
      t.string :short_url

      t.timestamps
    end

    add_index :members, :url, if_not_exists: true
  end
end
