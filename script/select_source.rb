#!/usr/bin/env ruby

require 'date'
require 'net/https'

yesterday = Date.today - 1
year = yesterday.strftime('%Y')
mp3_file = "lavenganza_#{yesterday.strftime('%Y-%m-%d')}.mp3"

SOURCES = [
  { url: "https://venganzasdelpasado.com.ar/st1/#{mp3_file}", min_size: 19_000_000 },
  { url: "https://venganzasdelpasado.com.ar/st/#{mp3_file}",  min_size: 25_000_000 },
  { url: "https://venganzasdelpasado.com.ar/st2/#{mp3_file}", min_size: 25_000_000 },
  { url: "https://venganzasdelpasado.com.ar/st3/#{mp3_file}", min_size: 20_000_000 }
].freeze

def get_file_length(url)
  uri = URI(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.request(Net::HTTP::Head.new(uri.request_uri))
  response ? response['content-length'].to_i : 0
end

dest_length = get_file_length "https://venganzasdelpasado.com.ar/#{year}/#{mp3_file}"

exit 0 if dest_length > 13_000_000

SOURCES.each do |source|
  url = source[:url]
  source_length = get_file_length url
  if source_length > source[:min_size]
    exec "/var/www/venganzasdelpasado.com.ar/current/script/retrieve_and_upload.sh #{url}"
  end
end

puts 'Ninguno sirve!'
exit 1
