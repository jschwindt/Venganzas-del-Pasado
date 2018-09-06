#!/bin/sh

DEST=/var/www/venganzasdelpasado.com.ar/st2
DATE=$(date +%F -d yesterday)
YEAR=$(date +%Y -d yesterday)
URL=https://radio3.dl.uy:9952/?type=http
DURATION=2:00:00
#DURATION=0:02:00

ffmpeg -y -loglevel info \
       -i ${URL} -t ${DURATION} \
       -codec:a libmp3lame -b:a 32k \
       -filter:a volume="replaygain=track:volume=0.4",compand="attacks=1:decays=4:soft-knee=6:points=-80/-80|-75/-25|0/0:gain=-6:volume=-30:delay=1" \
       \
       -metadata title="La venganza ${DATE}" \
       -metadata artist="Alejandro Dolina" \
       -metadata album="La venganza será terrible" \
       -metadata year="${YEAR}" \
       -metadata genre="Other" \
       -metadata comment="Programa de Dolina en Radio AM750 del ${DATE} http://venganzasdelpasado.com.ar/" \
       \
       ${DEST}/lavenganza_${DATE}.mp3

