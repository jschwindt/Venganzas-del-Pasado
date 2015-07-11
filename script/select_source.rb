#!/usr/bin/env ruby

require 'date'
require 'net/http'

yesterday = Date.today - 1
daystr = yesterday.strftime('%Y-%m-%d')
year   = yesterday.strftime('%Y')

SOURCES = [
  "http://venganzasdelpasado.com.ar/st/lavenganza_#{daystr}.mp3",
  "http://venganzasdelpasado.com.ar/st3/lavenganza_#{daystr}.mp3",
  "http://venganzasdelpasado.com.ar/st2/lavenganza_#{daystr}.mp3",
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

exit 0 if dest_length > 25_000_000

SOURCES.each do |url|
  source_length = get_file_length url
  puts "#{url} => #{source_length}"
  if source_length > 25_000_000
    exec "/var/www/venganzasdelpasado.com.ar/app/script/retrieve_and_upload.sh #{url}"
  end
end

puts "Ninguno sirve!"
exit 1

