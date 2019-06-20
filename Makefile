SHELL:=/bin/bash
.SHELLFLAGS = -e
.ONESHELL:

log_green = (printf '\x1B[32m>> $1\x1B[39m\n')
log_red = (>&2 printf '\x1B[31m>> $1\x1B[39m\n' && exit 1)
log_blue = (printf '\x1B[94m>> $1\x1B[39m\n')

comma := ,

clustername = localcluster
required_services = base
all_services = cassandra flink hbase hive redis spark
selected_services ?= hive flink

.SILENT: help
.PHONY: help # List of make targets and usage info
help:
	grep -Hs '^.PHONY: .* #' $$(find . -iname "Makefile" -o -iname "*.mk" | xargs echo) | sed "s/\(.*\):\.PHONY: \(.*\) # \(.*\)/`printf "\033[1;34m"`\2`printf "\033[0m"`	`printf "\033[1;37m"`\1`printf "\033[0m"`	\3/" | expand -t40

.SILENT: wait
.PHONY: wait # Sleep for "t" seconds, sleep until next minute if "t" is omitted
wait:
	$(eval t ?= $(shell bash -c 'echo $$((60 - 10#$$(date +"%S")))'))
	echo "Sleeping for $(t) seconds"
	sleep $(t)

.SILENT: stop
.PHONY: stop # Stops all docker containers and removes volumes
stop:
	$(call log_blue,Stopping cluster$(comma) removing volumes)
	docker-compose -p $(clustername) $(patsubst %,-f dc_%.yml,$(required_services) $(selected_services)) down -v --remove-orphans

.SILENT: start
.PHONY: start # Starts containers
start:
	$(call log_blue,Starting cluster)
	docker-compose -p $(clustername) $(patsubst %,-f dc_%.yml,$(required_services) $(selected_services)) up -d --remove-orphans --build --force-recreate

.SILENT: reset
.PHONY: reset # Resets containers and removes volumes
reset: stop start

.SILENT: list
.PHONY: list # Lists docker containers
list:
	for s in $$(docker-compose -p $(clustername) $(patsubst %,-f dc_%.yml,$(required_services) $(all_services)) ps -q); do servicename=$$(docker inspect --format "{{ .Name }}" $$s); ipaddress=$$(docker inspect --format "{{ .NetworkSettings.Networks.$(clustername)_default.IPAddress }}" $$s); printf "$$ipaddress\t$${servicename:1} \n"; done

.SILENT: logs
.PHONY: logs # Tail logs of container "c"
logs:
	@docker-compose -p $(clustername) $(patsubst %,-f dc_%.yml,$(required_services) $(all_services)) logs -f -t $(c)

# docker cp projects/flink/target/flink-0.0.1.jar taskmanager:/
# docker exec -it taskmanager "flink run /flink-0.0.1.jar"
# docker exec -it kafka1 "kafka-console-producer.sh --broker-list kafka1:9092 --topic flink_input"
# docker exec -it kafka1 "kafka-console-consumer.sh --bootstrap-server kafka1:9092 --topic flink_input"