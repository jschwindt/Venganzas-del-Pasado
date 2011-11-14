class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :alias, :string, :null => false
    add_column :users, :fb_userid, :string
    add_column :users, :slug, :string
    add_column :users, :role, :string
    add_column :users, :karma, :integer

    add_index :users, :alias
    add_index :users, :slug
    add_index :users, :fb_userid
  end
end
