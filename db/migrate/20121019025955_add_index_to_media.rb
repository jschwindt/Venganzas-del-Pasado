class AddIndexToMedia < ActiveRecord::Migration
  def change
    add_index :media, :post_id
  end
end
