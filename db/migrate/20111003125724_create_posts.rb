class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string  :title
      t.text    :content
      t.integer :comments_count, :default => 0
      t.string  :status
      t.string  :slug
      t.timestamps
    end
    add_index :posts, :slug, :unique => true
  end
end
