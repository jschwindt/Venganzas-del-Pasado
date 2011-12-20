class AddSomeIndexes < ActiveRecord::Migration
  def change
    add_index :posts, :created_at
    add_index :comments, :created_at
  end
end
