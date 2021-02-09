#!/bin/bash

URL=${1:-http://streaming.espectador.com/envivo}
DEST=${2:-/var/www/venganzasdelpasado.com.ar/st3}
DURATION=${3:-2:00:00}
DATE=${4:-$(date +%F -d yesterday)}
YEAR=${5:-$(date +%Y -d yesterday)}

echo "Downloading from $URL to $DEST for $DURATION (date: $DATE, year: $YEAR)"

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
       -metadata comment="Programa de Dolina en Radio AM750 del ${DATE} https://venganzasdelpasado.com.ar/" \
       -id3v2_version 3 \
       \
       ${DEST}/lavenganza_${DATE}.mp3
