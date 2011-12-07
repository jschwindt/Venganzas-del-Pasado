class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :slug
      t.text :content

      t.timestamps
    end
    add_index :articles, :slug, :unique => true
  end
end
