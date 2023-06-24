# WordPress Cache Warmer
This script is designed to retrieve an RSS feed from any website on WordPress and then execute cURL requests to cache new posts. It helps ensure that the latest posts with their amp version are cached and readily available for faster access.

## Installation
1. Download the script to your desired location.
2. Make the script executable by running the following command:
```shell
chmod +x wordpress_cache_warmer.sh
```
3. Set up a cron job to execute the script at regular intervals. For example, to run the script every minute, open your cron table by running:
```shell
crontab -e
```
4. Add the following line to the cron table:
```shell
* * * * * /path/to/wordpress_cache_warmer.sh domain.com >> /path/to/logfile.log 2>&1
```
Replace ```/path/to/wordpress_cache_warmer.sh``` with the actual path where you placed the script and ```domain.com``` with the target WordPress website's domain. Additionally, specify the desired path for the log file in ```/path/to/logfile.log```.
5. Save the changes and exit the editor.

## Script Explanation
1. The script starts by retrieving the RSS feed from the specified WordPress website using cURL and saving it to the ```rss_new.rss``` file.
```shell
curl -s https://$1/feed/ --output rss_new.rss
```
2. It then extracts the links from the RSS feed and saves them to the ```links.txt``` file.
```shell
grep "<link>https://$1/" rss_new.rss | sed 's/<link>//' | sed 's/<\/link>//' | sed 's/		//' > links.txt
```
3. Next, it compares the new links with the previously cached links stored in the ```links_old.txt``` file, saving any new links to the ```new.txt``` file.
```shell
grep -Fxvf links_old.txt links.txt | rev | cut -c 2- | rev > new.txt
```
4. The script removes the old ```links_old.txt``` file and renames ```links.txt``` to ```links_old.txt``` for future comparisons.
```shell
rm links_old.txt 
mv links.txt links_old.txt
```
5. If there are no new articles, the script outputs *No new articles.* Otherwise, it proceeds to execute cURL requests for each new link.
```shell
if [[ -z $(grep '[^[:space:]]' new.txt) ]] ; then
  echo "No new articles"
else
  while read p; do
    echo "cURLing $p/ ..."
    # cURL request to the link
    echo "done"
    echo "cURLing $p/amp/ ..."
    # cURL request to the AMP version of the link
    echo "done"
  done < new.txt  
fi
```
6. Finally, the script removes the temporary ```new.txt``` file.


Please note that it's essential to customize the cURL requests within the script according to your specific needs, such as setting appropriate user agents, headers, and other parameters. The script uses the user agent "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:108.0) Gecko/20100101 Firefox/108.0 cachewarmer" to emulate a real user, identify itself, allowing you to filter its traffic from your statistics.
