# encoding: utf-8

class Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged

  has_many :comments, :dependent => :destroy
  has_many :audios,   :dependent => :destroy
  has_many :media,    :dependent => :destroy
  accepts_nested_attributes_for :media

  attr_accessible :title, :content, :created_at, :media_attributes
  attr_accessible :title, :content, :created_at, :media_attributes, :status, :as => :admin

  validates :title, :presence => true
  validate :validate_status

  scope :published, where(:status => 'published')
  scope :lifo, order('created_at DESC')
  scope :this_month, where(:created_at => Date.today.beginning_of_month..Date.today.end_of_month)

  # Class methods
  class << self

    def statuses
      ['published', 'draft', 'deleted', 'pending', 'waiting']
    end

    def created_on(year, month = nil, day = nil)
      date = Date.new year.to_i

      if month.present?
        date = date.change( :month => month.to_i )
        if day.present?
          date = date.change( :day => day.to_i )
          range_date = date.beginning_of_day..date.end_of_day
        else
          range_date = date.beginning_of_month.beginning_of_day..date.end_of_month.end_of_day
        end
      else
        range_date = date.beginning_of_year.beginning_of_day..date.end_of_year.end_of_day
      end

      where(:created_at => range_date)
    end

    def post_count_by_month
      published.
      select('YEAR(created_at) AS year, MONTH(created_at) AS month, COUNT(*) AS count').
      group('year, month').
      order('year DESC, month DESC')
    end

    def create_from_audio_file(filename)
      if File.exists?(filename) && filename =~ /lavenganza_(\d{4})-(\d{2})-(\d{2}).mp3/
        day, mon, year = $3, $2, $1
        title = "La venganza será terrible del #{day}/#{mon}/#{year}"
        post = find_or_create_by_title(title)
        unless post.persisted?
          post.created_at = Time.zone.parse('#{year}-#{mon}-#{day} 03:00:00')
          post.status     = 'published'
          post.content    = ''
          audio           = Audio.find_or_initialize_by_url("http://venganzasdelpasado.com.ar/#{year}/lavenganza_#{year}-#{mon}-#{day}.mp3")
          audio.bytes     = File.size(filename)
          post.audios << audio
          post.save!
        end
      end
    end

    def new_contribution(params, user)
      # Elimina de params los media vacíos
      if params[:media_attributes].present?
        params[:media_attributes] = params['media_attributes'].select { |k, v| v['asset'].present? }
      end
      post = new(params)
      post.status = 'pending'
      post.created_at += 4.hours   # a las 4 de la mañana, para que no interfiera con los automáticos
      post.media.each do |medium|
        medium.contributor = user
      end
      # Agrega un media vacío si no hay ninguno, para que falle la validación
      post.media << Medium.new if post.media.size == 0
      post
    end

    def has_status(status)
      where( 'status = ?', status )
    end

  end   # Class methods

  def approve_contribution!
    self.status = 'waiting'
    save!
  end

  def creation_date
    self.created_at.to_datetime
  end

  def published?
    self.status == 'published'
  end

  def pending?
    self.status == 'pending'
  end

  def previous
    Post.lifo.published.where('created_at < ?', self.created_at).first
  end

  def next
    Post.lifo.published.where('created_at > ?', self.created_at).last
  end

  def description
    if content.present?
      desc = content.gsub(%r{</?[^>]+?>}, '').  # remove html tags
             gsub(%r{[#*\r\n-]+}, ' '). # remove some markdown
             truncate(200, :separator => ' ', :omission => '')
      desc.gsub(/\s+/, ' ').strip
    else
      "#{title} de Alejandro Dolina"
    end
  end

  define_index do
    indexes title
    indexes content
    has created_at
    where "status = 'published'"
  end

  protected

    def validate_status
      unless Post.statuses.include?(status)
        self.errors.add(:status, I18n.t("activerecord.errors.models.post.attributes.status.inclusion"))
      end
    end

end
