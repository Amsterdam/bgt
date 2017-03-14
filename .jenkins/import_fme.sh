#!/bin/sh

set -e
set -u

DIR="$(dirname $0)"

dc() {
	docker-compose -p bgt_import -f ${DIR}/docker-compose.yml $*
}

trap 'dc kill ; dc rm -f' EXIT

dc build
dc up -d database
dc test
dc run --rm importer

