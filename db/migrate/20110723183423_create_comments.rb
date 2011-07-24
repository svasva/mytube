class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :text
      t.integer :parent_id
      t.integer :video_id
      t.integer :user_id

      t.timestamps
    end
  end
end
