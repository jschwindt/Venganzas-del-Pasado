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

end