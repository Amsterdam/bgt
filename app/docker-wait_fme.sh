#!/usr/bin/env bash

set -u
set -e

# wait for postgres FME
while ! nc -z ${DATABASE_FME_1_PORT_5432_TCP_ADDR} ${DATABASE_FME_1_PORT_5432_TCP_PORT}
do
	echo "Waiting for postgres..."
	sleep 1
done
