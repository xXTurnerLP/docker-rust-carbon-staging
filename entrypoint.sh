#!/bin/bash

# Change Directory
cd /home/container

# Install steamdcmd
mkdir -p ./steamcmd
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxf - -C ./steamcmd/.

shopt -s nullglob # allow pattern matching failure to omit result instead of returning the pattern used

# Update server

if [[ "${STEAMCMD_UPDATE_SERVER}" == "1" ]]; then
	rm -rf /home/container/steamapps

	if [[ "${VALIDATE_SERVER_FILES}" == "1" ]]; then
		./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate -beta staging +quit
	else
		./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta staging +quit
	fi
fi

# Update carbon (uses carbon production)
curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar zx

# Copy harmony mod to fix the stdin
mkdir -p HarmonyMods
cp /LinuxStdinSupport.dll ./HarmonyMods/LinuxStdinSupport.dll


# Hijack carbon's startup command so we can inject our own script
sed -i "10c\
source ./start_server.sh
" carbon.sh
if [[ "${USING_ORIGINAL_START_SERVER_SCRIPT}" == "1" ]]; then
	cp /start_server.sh ./start_server.sh
fi

# Run server
chmod +x ./carbon.sh
./carbon.sh