#!/bin/bash


#Path to status-file for autoshutdown.d
statusFilePath='/tmp/mc.status'
#Path of logfile
logPath='/var/log/autoshutdown-plugins.log'

### Gets scripts dir ###
# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

#Gets the current player count on MC
function getPlayerCount {
  #Gets server-information with "list" command
  docker exec game-minecraft-paper rcon-cli list \
    | cut -d" " -f3
}


#Puts player count into var
PlayerCnt=$(getPlayerCount)

#Regex: Checks if it a number
z_re='^[0-9]+$'

#Pushes PlayerCnt to Prometheus
echo "pushgateway_mc_playerCnt $PlayerCnt" | curl --data-binary @- http://127.0.0.1:9091/metrics/job/playerCnt


##OLD: if [ $PlayerCnt -gt 0 ]
if [[ $PlayerCnt =~ $z_re ]] && [ "x$PlayerCnt" != "x0" ]; then
  if ! ls -1 "$statusFilePath" > /dev/null 2>&1 || [ "x$PlayerCnt" != "x$(cat $statusFilePath)" ]; then
    #echo "MC - Shutdown denied; Player count is $PlayerCnt; Creating $statusFilePath"
    logger -s "MC  - Shutdown denied; Player count is $PlayerCnt; Creating $statusFilePath" 2>> $logPath
  fi
  echo $PlayerCnt > "$statusFilePath"
else
  #echo "MC - Shutdown allowed; Player count is $PlayerCnt"
  #Checks if status-file exists
  if ls -1 "$statusFilePath" > /dev/null 2>&1; then
    #Deletes the status file
    #echo "MC - Shutdown allowed; Player count is $PlayerCnt; Deleting $statusFilePath"
    logger -s "MC  - Shutdown allowed; Player count is $PlayerCnt; Deleting $statusFilePath" 2>> $logPath
    rm "$statusFilePath"
  fi
fi


# Zeit Info wo ebenfalls Anz an Players drinnen stehen an
# ./rcon-cli --host 192.168.178.100 --port 27015 --password DerHardi status

# Zeigt nur Reihe mit Players an
# | grep players

# Funktioniert
# | grep players | cut -d: -f2 | rev | cut -d'(' -f2 | rev | tr -d ' '
