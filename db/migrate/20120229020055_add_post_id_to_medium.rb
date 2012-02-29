class AddPostIdToMedium < ActiveRecord::Migration
  def change
    add_column :media, :post_id, :integer
  end
end
