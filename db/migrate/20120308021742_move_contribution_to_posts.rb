class MoveContributionToPosts < ActiveRecord::Migration
  def change
    remove_column :media, :contributor_id
    add_column :posts, :contributor_id, :integer
  end
end
