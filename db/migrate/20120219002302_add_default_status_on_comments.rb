class AddDefaultStatusOnComments < ActiveRecord::Migration
  def change
    change_column :comments, :status, :string, :default => 'neutral'
  end

end
