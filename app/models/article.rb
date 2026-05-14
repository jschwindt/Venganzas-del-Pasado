class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: %i[slugged finders]

  validates :title, :content, presence: true

  def description
    # remove html tags
    desc = content
      .gsub(%r{</?[^>]+?>}, "")
      # remove some markdown
      .gsub(/[_#*\r\n-]+/, " ")
      .truncate(200, separator: " ", omission: "")
    desc.gsub(/\s+/, " ").strip
  end
end
