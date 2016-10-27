#!/bin/bash

GML=$1
object=$2
tabel=$3
locatie_GML=$4
db_server=$5
database=$6
db_port=$7
db_user=$8
# wachtwoord kan niet worden meegegegeven;
# aangenomen wordt dat dat wordt gezet in bestand <Linux-gebruiker>/.pgpass.
# (als dit niet is gedaan, moet het wachtwoord met de hand worden ingetikt
# voor ieder keer dat met een script de database wordt benaderd)
# BGT-database moet openstaan voor benadering van buitenaf;
# dit moet zijn geregeld in bestand pg_hba.conf.
# Zie voorbeeldbestandjes in submapje configuratie.

datum_tijd=$(date +"%Y%m%d_%H%M%S")


# echo
# echo Geef aantal features in objectklasse $object in GML-bestand $GML op locatie $locatie_GML
# Start dit shellscript geef_aantal_bestand_object_gml.sh door:
# sh geef_aantal_bestand_object_gml.sh bgt_put.gml put
# (of uiteraard andere bestands- en laagnamen)
# echo

aantal_bestand_object_gml=$(sh geef_aantal_bestand_object_gml.sh $GML $object $locatie_GML)

# echo
# echo Geef aantal rijen in tabel $tabel in database $database op db_server $db_server met poort $db_port en gebruiker $db_user
# Start dit shellscript vergelijk_aantal_bestand_object_gml_tabel_db.sh door:
# sh vergelijk_aantal_bestand_object_gml_tabel_db.sh $tabel (bv. imgeo_paal) $db_server $database $db_port $db_user
# als parameters 2 t/m 5 niet zijn gevuld, wordt ontwikkel-BGT-database DataPunt benaderd
# echo

aantal_tabel_db=$(sh geef_aantal_tabel_db.sh $tabel $db_server $database $db_port $db_user)

# test of aantalsvariabelen leeg zijn of tekst "ERROR" of "FAILURE" bevatten

if [ "$aantal_tabel_db" = "" -o "$aantal_bestand_object_gml" = "" -o "$aantal_tabel_db" = *"ERROR"* -o "$aantal_bestand_object_gml" = *"ERROR"* -o "$aantal_tabel_db" = *"FAILURE"* -o "$aantal_bestand_object_gml" = *"FAILURE"* ]
  then
    # geen data: geen vergelijking mogelijk
    printf "%-31.39s   :                                           ;\n" $tabel
	# 2>&1 | tee log/vergelijk_aantal_bestand_object_gml_tabel_db.$tabel.$datum_tijd.log
  else
    # echo
    # echo $vergelijk_aantal_bestand_object_gml_tabel_db
    # echo vergelijk aantal features in objectklasse met rijen in tabel
    # echo 'geef "0" als verschilaantal gelijk is aan 0 (nul)'
    # echo 'geef verschilmelding 'VERSCHIL: $verschilaantal' als verschil ongelijk is aan 0 (nul)'
    # echo
    vergelijk_aantal_bestand_object_gml_tabel_db=$(expr $aantal_bestand_object_gml - $aantal_tabel_db)
    # echo
#    if test $vergelijk_aantal_bestand_object_gml_tabel_db = 0
    if test "$vergelijk_aantal_bestand_object_gml_tabel_db" = "0"
      then
        # geen verschil
        printf "%-31.39s   : %8s ; %8s ;            %8s ;\n" $tabel $aantal_bestand_object_gml $aantal_tabel_db $vergelijk_aantal_bestand_object_gml_tabel_db
		# 2>&1 | tee log/vergelijk_aantal_bestand_object_gml_tabel_db.$tabel.$datum_tijd.log
      else
        # wel verschil
        printf "%-31.39s   : %8s ; %8s ; VERSCHIL : %8s ;\n" $tabel $aantal_bestand_object_gml $aantal_tabel_db $vergelijk_aantal_bestand_object_gml_tabel_db
		# 2>&1 | tee log/vergelijk_aantal_bestand_object_gml_tabel_db.$tabel.$datum_tijd.log
    fi
fi

# Bovenstaande geeft de volgende uitvoer (aantal features in objectklassen minus aantal rijen in tabel in database):
# 'als die gelijk zijn aan elkaar      :            0              '
# 'als die niet gelijk zijn aan elkaar : VERSCHIL : $verschilaantal'
#


# ""
# "*******************************************************************************"
# "* Klaar met vergelijken aantal features GML-best. met rijen tabel DB.         *"
# "*******************************************************************************"
# "" 
