#!/bin/sh

HOME=/var/www/venganzasdelpasado.com.ar/st3
DURATION=7512
DATE=`/bin/date +%F -d yesterday`

cd $HOME
/bin/rm -rf lvst?.*

# El Espectador
/usr/bin/cvlc http://streaming.espectador.com/envivo --sout file/asf:lvst0.asf &
/bin/sleep $DURATION
kill $!

/usr/bin/nice -n 15 /usr/bin/mplayer -ao pcm:file=lvst0.wav lvst0.asf
/usr/bin/nice -n 15 /usr/bin/sox lvst0.wav -c 1 --replay-gain track lvst1.wav vol 0.4 compand 1,4 6:-80,-80,-75,-25,0,0 -6 -30 1

/usr/bin/lame --quiet -v -h -B24 \
 --tl "La venganza sera terrible" \
 --tt "La venganza $DATE" \
 --tg "Other" \
 --ta "Alejandro Dolina" \
 --tc "Programa de Dolina en Radio del Plata del $DATE http://venganzasdelpasado.com.ar/" \
 lvst1.wav lavenganza_$DATE.mp3
