#!/bin/bash
SRC_FILE=ssh_servers.list
TMP_FILE=tmp_servers.list
SSH_PORT=22

if [[ $# -eq 0 ]]
  then
    echo -e "No arguments supplied!\n\nUsage: $0 {cpu|mem}\n"
    exit
fi

echo -e "\n=====\nStart\n=====\n\n"
sleep .5

function checkcpu(){
cat $TMP_FILE | xargs -I {} bash -c 'echo -e \
"\n=========================================\nGetting CPU info for host {}\n=========================================\n" \
&& ssh -i ~/.ssh/id_rsa root@{} cat /proc/cpuinfo'
}
function checkmem(){
cat $TMP_FILE | xargs -I {} bash -c 'echo -e \
"\n=========================================\nGetting MEM info for host {}\n=========================================\n" \
&& ssh -i ~/.ssh/id_rsa root@{} free -m'
}

echo -e "Cleaning temp file...\n\n"
cat /dev/null > $TMP_FILE
sleep .5

echo -e "Done...\n\n"
sleep .5

echo -e "Running pre-flight checks...\n\n"
sleep .5

if [ ! -f $SRC_FILE ]
  then
    echo -e "Source file not found [\e[31mFailed\e[0m]\nTerminating...\n\n"
    exit
  else
    echo -e "Source file exists [\e[32mOk\e[0m]\n\n"
    sleep .5
    if [ ! -s $SRC_FILE ]
    then
      echo -e "Source file is empty [\e[31mFailed\e[0m]\nTerminating...\n\n"
      exit
    else
      echo -e "Source file isn't empty [\e[32mOk\e[0m]\n\n"
      echo -e "Running hosts availability check...\n\n"
      sleep .5
      for host in $(cat $SRC_FILE)
      do
        nc -z -w 1 $host $SSH_PORT > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          echo -e "Host $host is available, addind to $TMP_FILE...\n"
          echo $host >> $TMP_FILE
          sleep .5
        else
          echo -e "Host $host is dead, ignoring...\n"
          sleep .5
        fi
      done
      echo -e "Availability check finished...\n"
      sleep .5
    fi
fi

case $1 in
cpu)
checkcpu
echo -e "\n========\n\e[32mAll done\e[0m\n========\n"
;;
mem)
checkmem
echo -e "\n========\n\e[32mAll done\e[0m\n========\n"
;;
*)
echo -e "\nWrong argument supplied!\nUsage: $0 {cpu|mem}\n"
;;
esac
