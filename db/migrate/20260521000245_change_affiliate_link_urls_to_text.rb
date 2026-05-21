class ChangeAffiliateLinkUrlsToText < ActiveRecord::Migration[8.1]
  def change
    change_column :affiliate_links, :product_url, :text
    change_column :affiliate_links, :affiliate_url, :text
    change_column :affiliate_links, :image_url, :text
  end
end
