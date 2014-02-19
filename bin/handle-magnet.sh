#!/bin/bash
watch_folder=~/.rtorrent/watch/start
cd $watch_folder

[[ "$1" =~ xt=urn:btih:([^&/]+) ]] || exit
hashh=${BASH_REMATCH[1]}
if [[ "$1" =~ dn=([^&/]+) ]];then
  filename=${BASH_REMATCH[1]}
else
  filename=$hashh
fi
echo "d10:magnet-uri${#1}:${1}e" > "meta-$filename.torrent"
