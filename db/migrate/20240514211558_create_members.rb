class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.string :name
      t.string :full_url
      t.string :short_url

      t.timestamps
    end

    add_index :members, :name, if_not_exists: true
    add_index :members, :full_url, if_not_exists: true
    add_index :members, :short_url, if_not_exists: true
  end
end
