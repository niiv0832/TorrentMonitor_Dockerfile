# All-In-One Docker container with TorrentMonitor, Rclone, Http-knocking
#
### TorrentMonitor 
*version ``1.8.2``, ``nginx``, ``php7.3``, ``sqlite``* _at Debian base Docker container_ 

**TorrentMonitor** - monitoring torrent site, downloads torrent files based on a user-defined filter, and much more.

For more informations about TorrentMonitor read <a href="http://www.tormon.ru">TorrentMonitor official site</a> and <a href="https://github.com/ElizarovEugene/TorrentMonitor">github project page</a> or join to <a href="https://t.me/joinchat/DFRbKQvV_FQA8TatJjlWRw">Project Telegram chat</a>.

TorrentMonitor support next trackers:
`anidub.com`, `animelayer.ru`, `baibako.tv`, `booktracker.org`, `casstudio.tv`, `hamsterstudio.org`, `kinozal.me`, `lostfilm.tv`, `newstudio.tv`, `nnmclub.to`, `pornolab.net`, `riperam.org`, `rustorka.com`, `rutor.info`, `rutracker.org`, `tfile.cc`, `tracker.0day.kiev.ua`, `tv.mekc.info`. 
#
### Rclone 
*version ``1.50.2``*

**Rclone** - is a command line program to sync files and directories to and from cloud storage (for example Google Drive).

For more informations about read <a href="https://rclone.org">Rclone official site</a> and <a href="https://github.com/rclone/rclone">github project page</a>. 
#
### Http-knocking 
*version ``0.8.4``*

**HTTP-Knocking** hides a Web server and open it by knocking sequence: Hide Web server until your knocks.

For more informations about read <a href="https://github.com/nwtgck/http-knocking">github project page</a>. 
#

This combo Docker container buid for use at publick server (like VPS). For use at private network you may use lite version with standalone TorrentMonitor (```docker pull niiv0832/tormon:lite```).

#
### Links:
Link on docker hub: <a href="https://hub.docker.com/r/niiv0832/tormon">niiv0832/tormon</a>

Link on github: <a href="https://www.github.com/niiv0832/TorrentMonitor_Dockerfile">niiv0832/TorrentMonitor_Dockerfile</a>

#

## Usage

```shell
docker run -d --name torrentmonitor --restart=always -p 55443:2000 -v $YOUR_PATH_TO_CONFIG_DIR$:/scripts -v $YOUR_PATH_TO_TORRENTS_DIR$:/data/htdocs/torrents -v $YOUR_PATH_TO_SQLITE.DB_DIR$:/data/htdocs/db -t niiv0832/tormon:latest
```
_$YOUR_PATH_TO_CONFIG_DIR$_:**/scripts** - thsi directory must contain _config and script files_ (all files name must be as writedown) for:
#### rclone: 
  * __rclone.conf__ - files with rclone configurations (you may read at <a href="https://rclone.org">Rclone official site</a> HOWTO create config for different cloud service.

Example of rclone.conf:
```
[remote]
type = drive
scope = drive
token = {"access_token":"$.......past..here....$","token_type":"Bearer","refresh_token":"$.......past..here....$","expiry":"2100-12-59T22:42:54.679710289+03:00"}
root_folder_id = $.......past..here....$
```
   * __rclonesync.sh__ - script to run rclone (this script added to crontab)
  
  Example of rclonesync.sh:
```
#!/bin/sh
findfileL=$(ls -l /data/htdocs/torrents | grep -v ^l | wc -l | sed 's/[^0-9]*//g')
if [ "$findfileL" -ne "0" ]
then
rclone move /data/htdocs/torrents/ remote:/vpssync/torrents/
else
echo "Nothing to upload"
fi
```
  
* http-knocking
  * __httpknocking.sh__ - script with config to run http-knocking
  
  Example of httpknocking.sh:
```
http-knocking -d --port=2000 \
                              --target-host=localhost \
                              --target-port=80 \
                              --open-knocking="/alpha,/foxtrot,/lima" \
                              --close-knocking="/close,/out" \
                              --auto-close-millis=600000 & \ 
exit 0
```
  http-knocking port must be ``2000`` and target-porr must be ``80``

* _$YOUR_PATH_TO_TORRENTS_DIR$_:**/data/htdocs/torrents** - to this folder TorrentMonitor will *downloade .torrent files*.

* _$YOUR_PATH_TO_SQLITE.DB_DIR$_:**/data/htdocs/db** - at this folder TorrentMonitor will *store sqlite database*, so DB will be save even you updating Docker container.    

_At you local comuters with torrent clients you may run script (put at crontab) like that:_

_Example of local script to receive remote files and put it in autoload folder:_
```
#!/bin/bash
findfile=$(rclone size remote:/torrents | grep objects | sed 's/[^0-9]*//g')
if [ "$findfile" -ne "0" ]
then
rclone move remote:/vpssync/btautoload /usr/torrentclient/.btautoload
else
echo "Nothing for download"
fi
```

**For Lite version**

```shell
docker run -d --name tormonlite --restart=always -p 55443:80 -v $YOUR_PATH_TO_TORRENTS_DIR$:/data/htdocs/torrents -v $YOUR_PATH_TO_SQLITE.DB_DIR$:/data/htdocs/db -t niiv0832/tormon:lite
```
For lite version only 2 directory need to map with container:

* _$YOUR_PATH_TO_TORRENTS_DIR$_:**/data/htdocs/torrents** - to this folder TorrentMonitor will *downloade .torrent files*.

* _$YOUR_PATH_TO_SQLITE.DB_DIR$_:**/data/htdocs/db** - at this folder TorrentMonitor will *store sqlite database*, so DB will be save even you updating Docker container.   
