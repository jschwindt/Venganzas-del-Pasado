class Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged

  has_many :comments, :dependent => :destroy
  has_many :audios,   :dependent => :destroy

  validates :title, :presence => true

  scope :published, where(:status => 'published')
  scope :lifo, order('created_at DESC')


  def self.created_on(year, month = nil, day = nil)
    date = Date.new year.to_i

    if month.present?
      date = date.change( :month => month.to_i )
      if day.present?
        date = date.change( :day => day.to_i )
        range_date = date.beginning_of_day..date.end_of_day
      else
        range_date = date.beginning_of_month..date.end_of_month
      end
    else
      range_date = date.beginning_of_year..date.end_of_year
    end

    where(:created_at => range_date)
  end
end
