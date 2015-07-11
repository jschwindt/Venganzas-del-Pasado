#!/bin/sh

HOME=/var/www/venganzasdelpasado.com.ar/st
DURATION=7519
DATE=`/bin/date +%F -d yesterday`

cd $HOME
/bin/rm -rf lvst?.*

export TERM=xterm

/usr/bin/mplayer -really-quiet -cache 256 -ao pcm:file="lvst0.wav" http://lsddelplatahls-lh.akamaihd.net/i/amdelplataHLS_1@126173/master.m3u8 &
/bin/sleep $DURATION
kill $!

/usr/bin/sox lvst0.wav -c 1 lvst1.wav vol 0.3 compand 0.3,1 6:-70,-60,-20 -8 -90 0.2

/usr/bin/lame --quiet -v -h -B24 \
 --tl "La venganza sera terrible" \
 --tt "La venganza $DATE" \
 --tg "Other" \
 --ta "Alejandro Dolina" \
 --tc "Programa de Dolina en Radio del Plata del $DATE http://venganzasdelpasado.com.ar/" \
 lvst1.wav lavenganza_$DATE.mp3

