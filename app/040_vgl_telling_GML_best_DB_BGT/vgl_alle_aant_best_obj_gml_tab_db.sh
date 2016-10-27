#!/bin/bash

locatie_GML=$1
db_server=$2
database=$3
db_port=$4
db_user=$5
# wachtwoord kan niet worden meegegegeven;
# aangenomen wordt dat dat wordt gezet in bestand <Linux-gebruiker>/.pgpass.
# (als dit niet is gedaan, moet het wachtwoord met de hand worden ingetikt
# voor ieder keer dat met een script de database wordt benaderd)
# BGT-database moet openstaan voor benadering van buitenaf;
# dit moet zijn geregeld in bestand pg_hba.conf.
# Zie voorbeeldbestandjes in submapje configuratie.

whoami=$(whoami)
who_m=$(who -m)
working_dir=$(pwd)
datum_tijd=$(date +"%Y%m%d_%H%M%S")


# echo
# echo Vergelijk aantallen van alle equivalente entiteiten,
# en geef daarvan de naam,aantal features in GML-objectklasse, aantal rijen in tabel,
# eventueel de tekst 'VERSCHIL : ' en $verschilaantal.
# Start daarvoor shellscript vgl_alle_aant_best_obj_gml_tab_db.sh door:
# sh vgl_alle_aant_best_obj_gml_tab_db.sh locatie_GML (=$1) db_server (=$2) database (=$3) db_port (=$4) db_user (=$5)
# echo

# verwijder oude tussenresultaten (geef_aantal_*.log en tel_*.log) vorige vergelijking GML en DB
rm -f log/tel_*.log
rm -f log/geef_*.log
# Let op: logbestanden VGL_ALLE_AANT-, VERSCHIL-, GEEN_DATA- en MELDING_best_obj_gml_tab_db.datum_tijd.log blijven beschikbaar.

echo
echo "-------------------------------------------------------------------------------"
echo "ParameterX: os_user     = ${whoami} / ${who_m}"
echo "ParameterY: working_dir = ${working_dir}"
echo "ParameterZ: datum_tijd  = ${datum_tijd}"
echo "Parameter0: script      = $0"
echo "Parameter1: locatie_GML = ${locatie_GML}"
echo "Parameter2: db_server   = ${db_server}"
echo "Parameter3: database    = ${database}"
echo "Parameter4: db_port     = ${db_port}"
echo "Parameter5: db_user     = ${db_user}"
echo "-------------------------------------------------------------------------------"
echo

echo
printf "%-31.39s   : %8s : %8s :            %8s\n" "Entiteit / Aantal" "GML" "DB" "Verschil :"
echo "-------------------------------------------------------------------------------"

sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_begroeidterreindeel.gml plantcover bgt_begroeidterreindeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_onbegroeidterreindeel.gml onbegroeidterreindeel bgt_onbegroeidterreindeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_ondersteunendwaterdeel.gml ondersteunendwaterdeel bgt_ondersteunendwaterdeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_ondersteunendwegdeel.gml auxiliarytrafficarea bgt_ondersteunendwegdeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_ongeclassificeerdobject.gml ongeclassificeerdobject bgt_ongeclassificeerdobject ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_openbareruimtelabel.gml openbareruimtelabel bgt_openbareruimtelabel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_overbruggingsdeel.gml bridgeconstructionelement bgt_overbruggingsdeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_pand.gml buildingpart bgt_pand ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_plaatsbepalingspunt.gml plaatsbepalingspunt bgt_plaatsbepalingspunt ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_tunneldeel.gml tunnelpart bgt_tunneldeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_waterdeel.gml waterdeel bgt_waterdeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_wegdeel.gml trafficarea bgt_wegdeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}

sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_bak.gml bak imgeo_bak ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_bord.gml bord imgeo_bord ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_functioneelgebied.gml functioneelgebied imgeo_functioneelgebied ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_gebouwinstallatie.gml buildingInstallation imgeo_gebouwinstallatie  ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_installatie.gml installatie imgeo_installatie ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_kast.gml kast imgeo_kast ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_kunstwerkdeel.gml kunstwerkdeel imgeo_kunstwerkdeel ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_mast.gml mast imgeo_mast ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_overigbouwwerk.gml overigbouwwerk imgeo_overigbouwwerk ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_overigescheiding.gml overigescheiding imgeo_overigescheiding ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_paal.gml paal imgeo_paal ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_put.gml put imgeo_put ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_scheiding.gml scheiding imgeo_scheiding ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_sensor.gml sensor imgeo_sensor ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_spoor.gml railway imgeo_spoor ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_straatmeubilair.gml straatmeubilair imgeo_straatmeubilair ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_vegetatieobject.gml solitaryvegetationobject imgeo_vegetatieobject ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_waterinrichtingselement.gml waterinrichtingselement imgeo_waterinrichtingselement ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}
sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_weginrichtingselement.gml weginrichtingselement imgeo_weginrichtingselement ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user}

echo "-------------------------------------------------------------------------------"
echo

# echo
# echo Bovenstaande geeft voor alle equivalente entiteiten de volgende uitvoer:
# echo de naam,aantal features in GML-objectklasse, aantal rijen in tabel,
# echo eventueel de tekst 'VERSCHIL : ' en $verschilaantal.
# echo Een grotendeels lege regel zonder aantallen of verschillen
# echo duidt of ontbreken data en dus op onmogelijkheid vergelijking.
# echo


echo
echo "*******************************************************************************"
echo "* Klaar met script $0 ..."
echo "* Klaar met voor alle equivalente entiteiten                                  *"
echo "* vergelijken aantal features GML-best. met rijen tabel DB.                   *"
echo "*******************************************************************************"
echo
