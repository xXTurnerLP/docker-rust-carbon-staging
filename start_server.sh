#!/bin/bash

cd /home/container

# setup log stuff
mkdir -p logs/archive
mv ./logs/*.log logs/archive

SERVER_STARTED_AT=$(date +%Y-%m-%d_%H:%M:%S)

./RustDedicated -logFile - -batchmode \
	+server.port ${SERVER_PORT} \
    $( [ -n "${QUERY_PORT}" ] && printf "+server.queryport ${QUERY_PORT}" ) \
    $( [ -n "${SERVER_IDENTITY}" ] && printf "+server.identity ${SERVER_IDENTITY}" ) \
    +server.gamemode "${GAMEMODE}" \
    +server.hostname "${HOSTNAME}" \
    +server.description "${DESCRIPTION}" \
    +server.url "${SERVER_URL}" \
	+server.headerimage "${SERVER_IMG}" \
	+server.logoimage "${SERVER_LOGO}" \
	+server.maxplayers ${MAX_PLAYERS} \
	$( [ -z ${MAP_URL} ] && printf "+server.worldsize \"${WORLD_SIZE}\" +server.seed \"${WORLD_SEED}\"" || printf "+server.levelurl ${MAP_URL}" ) \
	$( [ -n "${SERVER_TAGS}" ] && printf "+server.tags \"${SERVER_TAGS}\"" ) \
	${ADDITIONAL_ARGS} \
    | ts '[%Y-%m-%d %H:%M:%.S]' | tee -a ./logs/${SERVER_STARTED_AT}.log

# if the "Log ended" string is not in the logs, the docker container was killed forcefully
if [ $? -eq 0 ]; then
	printf "### Log ended. Server stopped cleanly @ $(date +%Y-%m-%d\ %H:%M:%S)" | ts '[%Y-%m-%d %H:%M:%.S]' | tee -a ./logs/${SERVER_STARTED_AT}.log
else
	printf "### Log ended. Server crashed with exit code '$?' @ $(date +%Y-%m-%d_%H:%M:%S)" | ts '[%Y-%m-%d %H:%M:%.S]' | tee -a ./logs/${SERVER_STARTED_AT}.log
fi
