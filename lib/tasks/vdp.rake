#encoding: utf-8

namespace :vdp do

  desc "Migra el contenido de la aplicación en WP"
  task :import => :environment do
#    require "wordpress"; Wordpress.import
    puts "Disabled!"
  end

  desc "Publica contribuciones"
  namespace :contribuciones do
    task :publish => :environment do
      Post.waiting.each do |post|
        post.publish_contribution
      end
    end
  end

  desc "Crea history de friendly_id"
  task :create_history => :environment do
    FriendlyId::Slug.where(:sluggable_type => 'User').delete_all
    u = User.find 'froilan'
    FriendlyId::Slug.create :sluggable_type => 'User', :sluggable_id => u.id, :slug => 'adolfo'
    u = User.find 'viyi'
    FriendlyId::Slug.create :sluggable_type => 'User', :sluggable_id => u.id, :slug => 'virginia'
    User.update_all :slug => nil
    User.find_each(&:save)
  end
end