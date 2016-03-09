#!/bin/sh

export PATH=/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

cd /home/jschwindt/podcast

YEAR=`/bin/date +%Y -d yesterday`
DATE=`/bin/date +%F -d yesterday`
DEST="/var/www/venganzasdelpasado.com.ar/$YEAR"
FILE="lavenganza_$DATE.mp3"

rm -rf lavenganza_*.mp3

echo "Fetching '$1'..."
/usr/bin/wget -q -N $1

if [ -s $FILE ]; then
  SIZE=$(/usr/bin/stat -c %s $FILE)
else
  SIZE=0
fi

if [ $SIZE -lt 13000000 ]; then
  echo "Error: el archivo $FILE tiene largo $SIZE o no existe!"
  exit 1
fi

/usr/bin/rsync -av $FILE $DEST/

/usr/bin/s3cmd -c /home/jschwindt/.s3cfg --acl-public put \
  $FILE \
  s3://s3.schwindt.org/dolina/$YEAR/$FILE

cd /var/www/venganzasdelpasado.com.ar/current
export RAILS_ENV=production
./script/rails runner "Post.create_from_audio_file('$DEST/$FILE')"
bundle exec rake sitemap:refresh
