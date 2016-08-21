#!/usr/bin/env bash

# TODO: Fix IP - set to database

bash -c "echo 192.168.1.10:5401:bgt:bgt:insecure" > ~/.pgpass && chmod 600 ~/.pgpass

#cd /app/010_download_BGT
#sh download_alle_BGT.sh

cd /app/020_aanmaak_DB_schemas_BGT
sh aanmaak_schemas_BGT.sh 192.168.1.10 bgt 5401 bgt
cd /app/060_aanmaak_tabel_FV_cntrl_BGT
sh aanmaak_tabellen_BGT.sh 192.168.1.10 bgt 5401 bgt
