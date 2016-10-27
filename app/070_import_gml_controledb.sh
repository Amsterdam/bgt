#!/bin/bash

locatie_GML=$1
db_server=$2
database=$3
db_port=$4
db_user=$5
db_schema=imgeo_gml

cd /tmp/data/
SRC_GML_FILES=`find *.gml -type f`

if [ "${SRC_GML_FILES}" ]; then

    PG="host=${db_server} port=${db_port} ACTIVE_SCHEMA=${db_schema} user=${db_user} dbname=${database}"
    LCO="-lco SPATIAL_INDEX=OFF"
    CONFIG="--config PG_USE_COPY YES"

    export PGCLIENTENCODING=UTF8;

    for SRC_GML_FILE in ${SRC_GML_FILES}; do
        echo "Importing: " ${SRC_GML_FILE};
        ogr2ogr -progress -skipfailures -overwrite -f "PostgreSQL" PG:"${PG}" -gt 65536 ${LCO} ${CONFIG} ${SRC_GML_FILE}
    done
fi
