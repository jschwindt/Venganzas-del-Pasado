class CreateAudios < ActiveRecord::Migration
  def change
    create_table :audios do |t|
      t.integer :post_id
      t.string :url
      t.integer :bytes
    end
    add_index :audios, :post_id
  end
end
