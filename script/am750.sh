#!/bin/sh

URL=`curl -s http://all.api.radio-browser.info/json/stations/byuuid/2b1094f2-9a8b-4444-8568-04f4ffaaee1f | jq -r ".[].url"`
DIR=/var/www/venganzasdelpasado.com.ar/st

/var/www/venganzasdelpasado.com.ar/current/script/with_ffmpeg.sh $URL $DIR
