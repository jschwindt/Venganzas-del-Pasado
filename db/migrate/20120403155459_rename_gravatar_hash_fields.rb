class RenameGravatarHashFields < ActiveRecord::Migration
  def change
    rename_column   :users,  :gravatar_hash, :profile_picture_url
    rename_column :comments, :gravatar_hash, :profile_picture_url
  end
end
