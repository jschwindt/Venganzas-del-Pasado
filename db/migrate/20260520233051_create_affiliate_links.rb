class CreateAffiliateLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :affiliate_links do |t|
      t.string :name
      t.string :product_url
      t.string :affiliate_url
      t.string :image_url
      t.float :price
      t.boolean :active

      t.timestamps
    end
  end
end
