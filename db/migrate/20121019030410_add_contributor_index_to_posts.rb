class AddContributorIndexToPosts < ActiveRecord::Migration
  def change
    add_index :posts, :contributor_id
  end
end
