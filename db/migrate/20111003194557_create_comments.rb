class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :post_id
      t.integer :user_id
      t.string  :author
      t.string  :author_email
      t.string  :author_ip
      t.text    :content
      t.string  :status
      t.timestamps
    end
    add_index :comments, [:post_id, :created_at]
    add_index :comments, :user_id
  end
end
