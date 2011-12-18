# encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Carga los artículos que están en db/articles/*. El nombre del archivo pasa a
# ser el título del artículo.

articles_path = File.join(Rails.root, 'db', 'articles')
base_pathname = Pathname.new(articles_path)
Dir[File.join(articles_path, '*')].each do |file|
  name = Pathname.new(file).relative_path_from(base_pathname).to_s

  article = Article.find_or_create_by_title(name)
  article.content = IO.read(file)
  article.save
  puts "Art. '#{name}' cargado."
end

