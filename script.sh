#!/bin/bash

## Recursively run commands on a directory and its sub directories;
## Properly strip metadata required to auto generate webpage links
## and deploy server via hexo-cli

IFS=$'\n'
fRoot='/home/dtrh/Videos/disney'
wRoot='/home/dtrh/Videos/website'
fList='files.lst'
cList='complete.lst'
nList='names.lst'
uList='url.lst'
serverPID=""
hostname="http://disney.rabbit-hole.ca:"

function cleanup() {
  cd $fRoot && rm $fList $tList $cList
  kill -9 $serverPID 2>&1 >/dev/null
}

function createPost() {
  cd $wRoot
  hostname="$hostname$port"
  npx hexo new post "Disney Movies"
  # Pseudocode 
  #while read l in $uList; do
  #  for (( i="$(cat $uList | wc -l)";$i -gt 0;i=$i-1)); do
  #     # work
  #  done
  #done 
}


function serveFiles() {

  local port=""

  read -p 'What port should be used? Default 80 : ' port 
  if [ ! $port ]; then port="80"; fi 
  for i in $(cat $cList); do echo -e "$hostname$port$i" >> $uList ; done 
  sed -i 's/m4v/.m4v/g' $uList && sed -i  's/mp4/.mp4/g' $uList \
  && sed -i  's/avi/.avi/g' $uList && sed -i 's/mkv/.mkv/g' $uList
  echo -e "\n\033[1;33mServing Files on port $port\033[0;37m"
  python2.7 -m SimpleHTTPServer  $port  2>&1 >/dev/null &
  serverPID=$!
}

function createList() {

  echo -e "\033[1;32mFinding files ..\033[0;37m" && cd $fRoot && sleep 0.5
  find . -type f > ${fList} &&   echo -e "\033[1;32mConfiguring file list for server ..\033[0;37m\n" && sleep 0.5

  while IFS="" read -r m || [ -n "$m" ]; do
    echo -e "$m" | awk -F"." '{ print $2.$3 }' >> $cList  ;
   echo "$(echo -e "$m" | awk -F"0s/" '{ print $2 }')" | awk -F. '{ print $1  }'  >> $nList ;
  done < $fList

  sed -i 's/ /%20/g' $cList  # /Disney%202010s/2016%20-%20Zootopia

}

main() {

  echo -e "\033[1;32mSetting Up..\033[0;37m" && sleep 0.5
  touch $fList $tList $cList

  createList
  serveFiles
  createPost
  cleanup
  
  exit 0
}

main


