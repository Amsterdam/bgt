#!/usr/bin/env bash

bash -c "echo database:5432:bgt:bgt:insecure" > ~/.pgpass && chmod 600 ~/.pgpass

cd /app/010_download_BGT
sh download_alle_BGT.sh

cd /app/070_import_gml_FV_cntrl_BGT
sh import_gml2db.sh /tmp/bgt/ database bgt 5432 bgt

cd /app/020_aanmaak_DB_schemas_BGT
sh aanmaak_schemas_BGT.sh database bgt 5432 bgt

cd /app/060_aanmaak_tabel_FV_cntrl_BGT
sh aanmaak_tabellen_BGT.sh database bgt 5432 bgt

cd /app/075_import_csv_FV_cntrl_BGT
sh import_mapping_GML_DB_CSV.sh CSV database bgt 5432 bgt

#TODO Create FME script here
#cd /app/030_inlezen_BGT

# TODO: NOT TESTED
#cd /app/090_aanmaak_VIEWS_BGT/aanmaak_views_bgt_dgn
#sh aanmaak_DB_views_BGT_DGN.sh database bgt 5432 bgt

#cd /app/090_aanmaak_VIEWS_BGT/aanmaak_views_bgt_shp
#sh aanmaak_DB_views_BGT_SHP.sh database bgt 5432 bgt

