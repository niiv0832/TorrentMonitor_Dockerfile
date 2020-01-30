# All-in one Docker container with TorrentMonitor, Rclone, Http-knocking
#
### TorrentMonitor 
*version ``1.8.2``, ``nginx``, ``php7.3``, ``sqlite``*

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

