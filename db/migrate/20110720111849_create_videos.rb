class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :source_content_type
      t.string :source_file_name
      t.text :source_meta
      t.integer :source_file_size
      t.string :current_state
      t.timestamps
    end
  end
end
