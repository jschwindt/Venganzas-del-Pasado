#!/bin/sh

export PATH=/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export RAILS_ENV=production

cd /var/www/venganzasdelpasado.com.ar/current
./bin/rails runner PublishService.new.run

. /home/jschwindt/vosk/.env
/home/jschwindt/vosk/.venv/bin/python /home/jschwindt/vosk/process_stt.py -m /home/jschwindt/vosk/model > /tmp/last_stt.log 2>&1