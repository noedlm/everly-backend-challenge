class CreateHeaders < ActiveRecord::Migration[6.1]
  def change
    create_table :headers do |t|
      t.references :member, null: false, foreign_key: true
      t.string :tag
      t.text :content

      t.timestamps
    end

    add_index :headers, :content, if_not_exists: true
  end
end
