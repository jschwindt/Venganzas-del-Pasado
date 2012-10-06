#!/bin/sh

HOME=/var/www/venganzasdelpasado.com.ar/st
DURATION=7212
DATE=`/bin/date +%F -d yesterday`

cd $HOME
/bin/rm -rf lvst?.*

/usr/bin/cvlc mms://active.telecomcdn.com/delplata/delplata --sout file/asf:lvst0.asf &

/bin/sleep $DURATION
kill $!

/usr/bin/mplayer -ao pcm:file=lvst0.wav lvst0.asf
/usr/bin/sox lvst0.wav -c 1 lvst1.wav mixer -l vol 0.3 compand 0.3,1 6:-70,-60,-20 -8 -90 0.2

/usr/bin/lame --quiet -v -h -B24 \
 --tl "La venganza sera terrible" \
 --tt "La venganza $DATE" \
 --tg "Other" \
 --ta "Alejandro Dolina" \
 --tc "Programa de Dolina en Radio del Plata del $DATE http://venganzasdelpasado.com.ar/" \
 lvst1.wav lavenganza_$DATE.mp3

