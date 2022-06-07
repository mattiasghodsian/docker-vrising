#!/bin/bash

# Environment variables
serverDir=/mnt/vrising/server
dataDir=/mnt/vrising/persistentdata
# dotnetDir=/mnt/vrising/persistentdata/dotnet

# Create directories
echo ">> Setting up file systems"
mkdir -p /root/.steam 2>/dev/null
# mkdir "$dotnetDir" 2>/dev/null
mkdir "$dir" 2>/dev/null

# Set directory permissions
chmod -R 777 /root/.steam 2>/dev/null
chmod -R 777 "$dotnetDir" 2>/dev/null

# Removes
# rm -R /tmp/* 2>/dev/null

# Set timezone
ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" >/etc/timezone

# Set default env variables values
if [ -z "$SERVERNAME" ]; then
	SERVERNAME="dockerizedVRising"
fi

if [ -z $WORLDNAME ]; then
	WORLDNAME="world1"
fi

if [ -z $AUTO_BACKUP ]; then
	AUTO_BACKUP=0
fi

if [ -z "$AUTO_BACKUP_SCHEDULE" ]; then
	AUTO_BACKUP_SCHEDULE="*/30 * * * *"
fi

if [ $AUTO_BACKUP -eq 1 ]; then
	service cron start
	crontab -l | { cat; echo "${AUTO_BACKUP_SCHEDULE} bash /home/steam/auto_backup.sh"; } | crontab -
fi

if [ -z "$DISCORD_WEBHOOK_URL" ]; then
	DISCORD_WEBHOOK_URL=0
fi

# Send message to discord
discordMsg(){
	sleep 1
	if [ $DISCORD_WEBHOOK_URL != 0 ]; then
		curl -i -H "Accept: application/json" -H "Content-Type:application/json" -X POST --data "{\"content\": \"$1\"}" ${DISCORD_WEBHOOK_URL} 2>/dev/null
	fi
}

cleanup() {
	discordMsg "Server shutting down..."
	trap - SIGINT SIGTERM # clear the trap
	kill -- -$$ # Sends SIGTERM to child/sub processes
}

trap cleanup SIGINT
trap cleanup SIGTERM

echo ">> Updating V-Rising Dedicated Server files..."

/usr/bin/steamcmd +force_install_dir "$serverDir" +login anonymous +app_update 1829350 +quit

cd "$serverDir"
set SteamAppId=`cat $serverDir/steam_appid.txt`
discordMsg "Starting ${SERVERNAME} server"
echo ">> Starting Xvfb and wine64 ..."
Xvfb :0 -screen 0 1024x768x16 &
DISPLAY=:0.0 wine64 /mnt/vrising/server/VRisingServer.exe -persistentDataPath $dataDir -serverName "${SERVERNAME}" -saveName "$WORLDNAME" -logFile "$dataDir/VRisingServer.log" 2>&1

/usr/bin/tail -f $dataDir/VRisingServer.log & wait $!