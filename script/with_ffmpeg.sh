#!/bin/bash

URL=${1:-http://streaming.espectador.com/envivo}
DEST=${2:-/var/www/venganzasdelpasado.com.ar/st3}
DURATION=${3:-2:00:00}
if [[ "$(uname)" == "Darwin" ]]; then
DATE=${4:-$(date -v -1d +%F)}
YEAR=${5:-$(date -v -1d +%Y)}
else
DATE=${4:-$(date +%F -d yesterday)}
YEAR=${5:-$(date +%Y -d yesterday)}
fi

echo "Downloading from $URL to $DEST for $DURATION (date: $DATE, year: $YEAR)"

ffmpeg -y -loglevel info \
       -i "${URL}" -t "${DURATION}" \
       -codec:a libmp3lame -b:a 64k \
       \
       -metadata title="La venganza ${DATE}" \
       -metadata artist="Alejandro Dolina" \
       -metadata album="La venganza será terrible" \
       -metadata year="${YEAR}" \
       -metadata genre="Other" \
       -metadata comment="Programa de Dolina en Radio AM750 del ${DATE} https://venganzasdelpasado.com.ar/" \
       -id3v2_version 3 \
       \
       "${DEST}/lavenganza_${DATE}.mp3"
