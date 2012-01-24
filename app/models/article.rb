class Article < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged

  validates :title, :presence => true

  def description
    if content.present?
      desc = content.gsub(/[#*\r\n-]+/, ' ').truncate(200, :separator => ' ', :omission => '')
      desc.gsub(/\s+/, ' ').strip
    else
      "#{title} de Alejandro Dolina"
    end
  end

end
