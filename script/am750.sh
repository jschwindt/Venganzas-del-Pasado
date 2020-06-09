#!/bin/sh

URL=`curl -s https://www.enlaradio.com.ar/listen/radio-am750_1147/ | grep source | grep -Po 'src="\K.*?(?=")'`
DIR=/var/www/venganzasdelpasado.com.ar/st

/var/www/venganzasdelpasado.com.ar/current/script/with_ffmpeg.sh $URL $DIR
