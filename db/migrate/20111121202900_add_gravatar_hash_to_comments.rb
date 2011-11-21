class AddGravatarHashToComments < ActiveRecord::Migration
  def change
    add_column :comments, :gravatar_hash, :string
    remove_column :comments, :updated_at
  end
end
