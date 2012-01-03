#!/usr/bin/env ruby

require 'date'
require 'net/http'

yesterday = Date.today - 1
daystr = yesterday.strftime('%Y-%m-%d')
year   = yesterday.strftime('%Y')

SOURCES = [
  "http://venganzasdelpasado.com.ar/st/lavenganza_#{daystr}.mp3",
   "http://sistema.carm.com.ar/podcast/lavenganza_#{daystr}.mp3",
   "http://www.schwindt.org/podcast/st/lavenganza_#{daystr}.mp3",
   "http://www.schwindt.org/podcast/am/lavenganza_#{daystr}.mp3",
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

exit 0 if dest_length > 20_000_000

SOURCES.each do |url|
  source_length = get_file_length url
  puts "#{url} => #{source_length}"
  if source_length > 20_000_000
    exec "/home/jschwindt/podcast/retrieve_and_upload.sh #{url}"
  end
end

puts "Ninguno sirve!"
exit 1

