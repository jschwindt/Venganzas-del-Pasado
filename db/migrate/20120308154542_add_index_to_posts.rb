class AddIndexToPosts < ActiveRecord::Migration
  def change
    add_index :posts, :updated_at
  end
end
