#!/usr/bin/env ruby

require 'date'
require 'yaml'

app_config_file = File.expand_path('../config/app_config.yml', __dir__)
app_config = YAML.load_file(app_config_file)[ENV['RAILS_ENV'] || 'development']

day = Date.today - (ARGV[0] || 1).to_i
year = day.strftime('%Y')
mp3_file = "lavenganza_#{day.strftime('%Y-%m-%d')}.mp3"

SOURCES = [
  { file: "/st0/#{mp3_file}",  min_size: 25_000_000 },
  { file: "/st1/#{mp3_file}", min_size: 19_000_000 },
  { file: "/st2/#{mp3_file}", min_size: 25_000_000 },
  { file: "/st3/#{mp3_file}", min_size: 20_000_000 }
].freeze

dest_file = "#{app_config['audios_root']}/#{year}/#{mp3_file}"

exit 0 if File.exist?(dest_file) && File.size(dest_file) > 15_000_000

SOURCES.each do |source|
  source_file = "#{app_config['audios_root']}#{source[:file]}"
  if File.exist?(source_file) && File.size(source_file) > source[:min_size]
    puts "SIRVE: #{source[:file]} (#{File.size(source_file) / (1024 * 1024)} Mb)"
    File.open("#{app_config['audios_root']}/publish/#{Time.now.to_i}.txt", 'w') do |f|
      f.write source[:file]
    end
    exit 0
  end
end

puts 'Ninguno sirve!'
exit 1
