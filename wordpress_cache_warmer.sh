#!/bin/bash

curl -s https://$1/feed/ --output rss_new.rss

grep "<link>https://$1/" rss_new.rss | sed 's/<link>//' | sed 's/<\/link>//' | sed 's/		//' > links.txt

grep -Fxvf links_old.txt links.txt | rev | cut -c 2- | rev > new.txt
rm links_old.txt 
mv links.txt links_old.txt

if [[ -z $(grep '[^[:space:]]' new.txt) ]] ; then
  echo "No new articles"
else
while read p; do
  echo "cURLing $p/ ..."
  curl -s -o /dev/null $p/ -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:108.0) Gecko/20100101 Firefox/108.0 cachewarmer' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: pl,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Connection: keep-alive'
  echo "done"
  echo "cURLing $p/amp/ ..."
  curl -s -o /dev/null $p/amp/ -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:108.0) Gecko/20100101 Firefox/108.0 cachewarmer' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: pl,en-US;q=0.7,en;q=0.3' -H 'Accept-Encoding: gzip, deflate, br' -H 'Connection: keep-alive' 
  echo "done"
done < new.txt  
fi
rm new.txt
