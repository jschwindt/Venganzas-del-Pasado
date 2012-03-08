class Article < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged

  validates :title, :content, :presence => true

  def description
    desc = content.gsub(%r{</?[^>]+?>}, '').  # remove html tags
           gsub(%r{[_#*\r\n-]+}, ' '). # remove some markdown
           truncate(200, :separator => ' ', :omission => '')
    desc.gsub(/\s+/, ' ').strip
  end

end
