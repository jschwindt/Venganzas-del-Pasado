class Article < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => [:slugged, :finders]

  validates :title, :content, :presence => true
  attr_accessible :title, :content, :as => :admin

  def description
    desc = content.gsub(%r{</?[^>]+?>}, '').  # remove html tags
           gsub(%r{[_#*\r\n-]+}, ' '). # remove some markdown
           truncate(200, :separator => ' ', :omission => '')
    desc.gsub(/\s+/, ' ').strip
  end

end
