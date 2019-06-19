#!/bin/bash

chmod +x /usr/local/bin/docker
chmod +x /usr/local/bin/redis-trib.rb

sleep 3;

VALID_REDIS_CONTAINERS=()

for i in `docker ps -a -q`; do
    IP=`docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$i"`
    X=$(exec 6<>"/dev/tcp/$IP/6379" || echo "No one is listening!")
    exec 6>&- # close output connection
    exec 6<&- # close input connection
    if [[ -z "$X" ]]; then
        VALID_REDIS_CONTAINERS+=($IP":6379");
    fi
done

echo "Valid Redis containers:" ${VALID_REDIS_CONTAINERS[*]}

redis-trib.rb create --replicas 1 ${VALID_REDIS_CONTAINERS[*]}
