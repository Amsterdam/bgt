#!/usr/bin/env bash

set -u
set -e

# wait for postgres TMP
while ! nc -z ${DATABASE_FME_PORT_5432_TCP_ADDR} ${DATABASE_FME_PORT_5432_TCP_PORT}
do
	echo "Waiting for postgres..."
	sleep 1
done

# wait for postgres BGT
while ! nc -z ${DATABASE_BGT_PORT_5432_TCP_ADDR} ${DATABASE_BGT_PORT_5432_TCP_PORT}
do
	echo "Waiting for postgres..."
	sleep 1
done