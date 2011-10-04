class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :post_id
      t.string  :author
      t.string  :author_email
      t.string  :author_url
      t.string  :author_ip
      t.text    :content
      t.timestamps
    end
  end
end
