#!/bin/sh

URL=`curl -s https://www.enlaradio.com.ar/listen/radio-am750_1147 | grep source | grep -Po 'src="\K.*?(?=")'`
HOME=/var/www/venganzasdelpasado.com.ar/st

./with_ffmpeg.sh $URL $HOME
