#encoding: utf-8

namespace :vdp do
  
  desc "Migra el contenido de la aplicación en WP"
  task :migrate => :environment do
    require "wordpress"; Wordpress.import
  end
  
end