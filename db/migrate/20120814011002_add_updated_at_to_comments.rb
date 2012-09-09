class AddUpdatedAtToComments < ActiveRecord::Migration
  def up
    add_column :comments, :updated_at, :timestamp

    Comment.all.each do |c|
      c.update_attribute :updated_at, c.created_at
    end
  end

  def down
    remove_column :comments, :updated_at
  end
end
