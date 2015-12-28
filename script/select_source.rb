#!/usr/bin/env ruby

require 'date'
require 'net/http'

yesterday = Date.today - 1
daystr = yesterday.strftime('%Y-%m-%d')
year   = yesterday.strftime('%Y')

SOURCES = [
  { url: "http://venganzasdelpasado.com.ar/st1/lavenganza_#{daystr}.mp3", min_size: 13_000_000 },
  { url: "http://venganzasdelpasado.com.ar/st3/lavenganza_#{daystr}.mp3", min_size: 25_000_000 },
  { url: "http://venganzasdelpasado.com.ar/st/lavenganza_#{daystr}.mp3",  min_size: 25_000_000 },
  { url: "http://venganzasdelpasado.com.ar/st2/lavenganza_#{daystr}.mp3", min_size: 25_000_000 },
]

def get_file_length(url)
  uri = URI.parse url
  response = nil
  Net::HTTP.start(uri.host, uri.port) do |http|
    response = http.head(uri.path)
  end
  response ? response['content-length'].to_i : 0
end

dest_length = get_file_length "http://venganzasdelpasado.com.ar/#{year}/lavenganza_#{daystr}.mp3"

exit 0 if dest_length > 13_000_000

SOURCES.each do |source|
  url = source[:url]
  source_length = get_file_length url
  puts "#{url} => #{source_length}"
  if source_length > source[:min_size]
    exec "/var/www/venganzasdelpasado.com.ar/app/script/retrieve_and_upload.sh #{url}"
  end
end

puts "Ninguno sirve!"
exit 1
