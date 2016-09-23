#!/usr/bin/env bash

cat > ~/.pgpass <<EOF
database:5432:bgt:bgt:insecure
${FMEHOST}:5432:gisdb:dbuser:${FMEDBPASS}
EOF

chmod 600 ~/.pgpass

cd /app/010_download_BGT
mkdir log
#sh START_SH_download_alle_BGT.sh

cd /app/
/usr/bin/python3 /src/connect.py

# pg_dump -Fc -U dbuser -d gisdb -h bgt-datapunt.fmecloud.com -p 5432 -v > /dump/bgt.dump
# pg_restore -j 4 -d bgt -h database -O -v -U bgt /dump/bgt.dump

# curl -X PUT --header "Content-Type: application/json" --header "Accept: application/json" --header "Authorization: Bearer ${FMESERVERAPI}" "https://api.fmecloud.safe.com/v1/instances/2432/pause"

# cd /app/020_aanmaak_DB_schemas_BGT
# sh START_SH_aanmaak_schemas_BGT.sh database bgt 5432 bgt

# cd /app/040_controle_telling_BGT
# mkdir log
# sh START_SH_vergelijk_alle_gml_db.sh /data/ database bgt 5432 bgt

# cd /app/060_aanmaak_tabel_FV_cntrl_BGT
# mkdir log
# sh START_SH_aanmaak_tabellen_BGT.sh database bgt 5432 bgt

# cd /app/070_import_gml_FV_cntrl_BGT
# mkdir log
# sh START_SH_import_gml2db.sh /data/ database bgt 5432 bgt

# cd /app/075_import_csv_FV_cntrl_BGT
# mkdir log
# sh START_SH_import_mapping_GML_DB_CSV.sh CSV database bgt 5432 bgt

# cd /app/080_controle_frequentieverdeling_BGT
# mkdir log
# sh tel_gml.sh database bgt 5432 bgt
# sh frequentieverdeling_gml.sh database bgt 5432 bgt
# sh tel_db.sh database bgt 5432 bgt
# sh frequentieverdeling_db.sh database bgt 5432 bgt

# cd /app/090_aanmaak_VIEWS_BGT/aanmaak_views_bgt_dgn
# mkdir log
# sh START_SH_aanmaak_DB_views_BGT_DGN.sh database bgt 5432 bgt

# cd /app/090_aanmaak_VIEWS_BGT/aanmaak_views_bgt_shp
# mkdir log
# sh START_SH_aanmaak_DB_views_BGT_SHP.sh database bgt 5432 bgt

