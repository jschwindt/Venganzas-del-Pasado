#!/bin/sh

HOME=/var/www/gambito/podcast/am
DATE=`/bin/date +%F -d yesterday`

cd $HOME

/bin/rm -f l*.mp3

/usr/bin/arecord -D plughw:0,0 -f S16_LE -c1 -r22050 -t wav -d 7200 | \
/usr/bin/lame --quiet -v -h -m m -B24 --resample 22.05 \
 --tl "La venganza sera terrible" \
 --tt "La venganza $DATE" \
 --tg "Other" \
 --ta "Alejandro Dolina" \
 --tc "Programa de Dolina en Radio Nacional del $DATE http://venganzasdelpasado.com.ar/" \
 - lavenganza_$DATE.mp3
 - am_$DATE.mp3

