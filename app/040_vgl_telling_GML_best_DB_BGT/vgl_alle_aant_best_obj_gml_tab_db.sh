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


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    vgl_alle_aant_best_obj_gml_tab_db.sh              *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT_BGT                                      *"
# "*                                                                             *"
# "* Module :                  Verwerving BGT                                    *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      START_SH_vergelijk_alle_gml_db.sh                 *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    vergelijk voor alle equivalente entiteiten        *"
# "*                           het aantal features in objectklasse in bestand    *"
# "*                           met aantal rijen in BGT_tabel                     *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* DATAPUNT-BGT-versienr :   1.00.0                                            *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Wijzigingsgeschiedenis :                                                    *"
# "*                                                                             *"
# "* auteur                    datum        versie   wijziging                   *"
# "* -----------------------   ----------   ------   --------------------------- *"
# "* Raymond Young, IV-BI      24-05-2016   1.00.0   RC1: initiele aanmaak       *"
# "* Raymond Young, IV-BI      24-05-2016   1.00.0   RC1: verwijder oude logs    *"
# "* Raymond Young, IV-BI      14-06-2016   1.00.0   RC1: wijz. stand.loc. GML   *"
# "* Raymond Young, IV-BI      12-07-2016   1.00.0   RC1: wijz. tabelnamen DB    *"
# "*                                                 voorvoegsel BGT_ -> IMGEO_  *"
# "* Raymond Young, IV-BI      14-07-2016   1.00.0   RC1: toev. voorbeeldaanroep *"
# "* Raymond Young, IV-BI      19-07-2016   1.00.0   RC1: - parameters -> log    *"
# "*                                                      - wijz. parameternamen *"
# "* Raymond Young, IV-BI      05-08-2016   1.00.0   RC1: - interpr. met bash    *"
# "*                                                      - wijz. volgorde vgl   *"
# "*                                                 op bgt-/imgeo-tabelnaam     *"
# "* Raymond Young, IV-BI      16-08-2016   1.00.0   RC1: wijz. logging params   *"
# "* Raymond Young, IV-BI      09-08-2016   1.00.0   RC1: gewijzigde logging     *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Parameter 1 :             locatie_GML           locatie GML-bestanden       *"
# "* Parameter 2 :             db_server             database-server BGT-gegevs  *"
# "* Parameter 3 :             database              database BGT-gegevens       *"
# "* Parameter 4 :             db_port               poort naar database-server  *"
# "* Parameter 5 :             db_user               gebruiker t.b.v. BGT        *"
# "*                                                                             *"
# "*******************************************************************************"
# ""


# Start dit script als volgt:
#
# sh vgl_alle_aant_best_obj_gml_tab_db.sh <LOCATIE_GML> <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh vgl_alle_aant_best_obj_gml_tab_db.sh ./GML/ 85.222.225.45 bgt_dev 8080 bgt
# (of uiteraard andere locatie- of database-gegevens)
# Als niet alle parameters 1 t/m 5 zijn gevuld, krijgen die een standaardwaarde (zie hieronder).


echo
echo "*******************************************************************************"
echo "* Start script $0 ..."
echo "* Start voor alle equivalente entiteiten vergelijking tussen                  *"
echo "* het aantal features in objectklasse in bestand                              *"
echo "* met aantal rijen in BGT_tabel ...                                           *"
echo "*******************************************************************************"
echo

if test "$#" -ne "5"
  then
    # als niet alle parameters 1 t/m 5 zijn gevuld,
	# worden GML-bestanden gezocht op locatie huidige directory
	# en wordt ontwikkel-BGT-database DataPunt benaderd
    # echo 'test $# -ne 5' : Vul variabelen met standaardwaarden ...
    if test "$1" = ""
      then
        locatie_GML='./GML/'
    fi
    if test "$2" = ""
      then
        db_server='85.222.225.45'
    fi
	if test "$3" = ""
      then
        database='bgt_dev'
    fi
    if test "$4" = ""
      then
        db_port='8080'
    fi
    if test "$5" = ""
      then
        db_user='bgt'
    fi
fi

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
