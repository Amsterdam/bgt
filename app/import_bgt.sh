#!/usr/bin/env bash

#cat > ~/.pgpass <<EOF
#database:5432:bgt:bgt:insecure
#${FMEHOST}:5432:gisdb:dbuser:${FMEDBPASS}
#EOF
#
#chmod 600 ~/.pgpass
#
#mkdir log
#
#cd /app/
/usr/bin/python3 /src/fme/connect.py
