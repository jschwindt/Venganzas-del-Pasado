class AddPostIdToMedium < ActiveRecord::Migration
  def change
    add_column :media, :post_id, :integer
    add_column :media, :contributor_id, :integer
  end
end
