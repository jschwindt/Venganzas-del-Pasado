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
      CarrierWave.clean_cached_files!
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

  desc "Actualiza profile_picture_url de usuarios y comentarios"
  namespace :avatars do
    task :update => :environment do
      puts "Actualizando Users"
      User.find_each(&:save)
      puts "Actualizando Comments"
      Comment.find_each(&:update_profile_picture_url)
    end
  end
end
