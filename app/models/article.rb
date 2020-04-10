class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: %i[slugged finders]

  validates :title, :content, presence: true

  def description
    desc = content.gsub(%r{</?[^>]+?>}, '') # remove html tags
                  .gsub(/[_#*\r\n-]+/, ' ') # remove some markdown
                  .truncate(200, separator: ' ', omission: '')
    desc.gsub(/\s+/, ' ').strip
  end
end
