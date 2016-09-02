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


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    vergelijk_aantal_bestand_object_gml_tabel_db.sh   *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT_BGT                                      *"
# "*                                                                             *"
# "* Module :                  Verwerving BGT                                    *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      vgl_alle_aant_best_obj_gml_tab_db.sh              *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    vergelijk voor (parameter) equivalente entiteit   *"
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
# "* Raymond Young, IV-BI      03-05-2016   1.00.0   RC1: initiele aanmaak       *"
# "* Raymond Young, IV-BI      24-05-2016   1.00.0   RC1: - logging uitgezet     *"
# "*                                                      - fout afwezige tabel  *"
# "*                                                        afgevangen           *"
# "* Raymond Young, IV-BI      31-05-2016   1.00.0   RC1: aanroep scripts met sh *"
# "* Raymond Young, IV-BI      06-06-2016   1.00.0   RC1: verbetering test op    *"
# "*                                                 voorwaarde aantal leeg      *"
# "*                                                 of ERROR (?)                *"
# "* Raymond Young, IV-BI      14-06-2016   1.00.0   RC1: wijz. stand.loc. GML   *"
# "* Raymond Young, IV-BI      12-07-2016   1.00.0   RC1: wijz. test aantalsvar  *"
# "*                                                 leeg of bevat ERROR/FAILURE *"
# "* Raymond Young, IV-BI      14-07-2016   1.00.0   RC1: wijz. voorbeeldaanroep *"
# "* Raymond Young, IV-BI      19-07-2016   1.00.0   RC1: wijz. parameternamen   *"
# "* Raymond Young, IV-BI      05-08-2016   1.00.0   RC1: interpr. met bash      *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Parameter 1 :             GML                   GML-bestand met BGT-gegevs  *"
# "* Parameter 2 :             object                objectlaag in GML-bestand   *"
# "* Parameter 3 :             tabel                 tabel BGT-gegevens          *"
# "* Parameter 4 :             locatie_GML           locatie GML-bestanden       *"
# "* Parameter 5 :             db_server             database-server BGT-gegevs  *"
# "* Parameter 6 :             database              database BGT-gegevens       *"
# "* Parameter 7 :             db_port               poort naar database-server  *"
# "* Parameter 8 :             db_user               gebruiker t.b.v. BGT        *"
# "*                                                                             *"
# "*******************************************************************************"
# ""


# Start dit script als volgt:
#
# sh vergelijk_aantal_bestand_object_gml_tabel_db.sh <GML> <OBJECT> <TABEL> <LOCATIE_GML> <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh vergelijk_aantal_bestand_object_gml_tabel_db.sh bgt_put.gml put bgt_put ./GML/ 85.222.225.45 bgt_dev 8080 bgt
# (of uiteraard andere GML-bestand en -object, tabel, locatie- of database-gegevens)
# Als parameters 4 t/m 8 niet zijn gevuld, krijgen die een standaardwaarde (zie hieronder).


# ""
# "*******************************************************************************"
# "* Query aftrappen bevraging BGT-/imgeo-tabellen ...                           *"
# "*******************************************************************************"
# ""

if test "$#" -eq "3"
  then
    # als parameters 4 t/m 8 niet zijn gevuld,
	# worden GML-bestanden gezocht op locatie huidige directory
	# en wordt ontwikkel-BGT-database DataPunt benaderd
    # echo 'test $# -eq 3' : Vul variabelen met standaardwaarden ...
    GML=$1
    object=$2
    tabel=$3
    if test "$4" = ""
      then
        locatie_GML='./GML/'
    fi
    if test "$5" = ""
      then
        db_server='85.222.225.45'
    fi
	if test "$6" = ""
      then
        database='bgt_dev'
    fi
    if test "$7" = ""
      then
        db_port='8080'
    fi
    if test "$8" = ""
      then
        db_user='bgt'
    fi
fi

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
