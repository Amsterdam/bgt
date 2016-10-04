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

datum_tijd=$(date +"%Y%m%d_%H%M%S")
logbestand=VGL_ALLE_AANT_best_obj_gml_tab_db.$datum_tijd.log
verschil_log=VERSCHIL_vgl_alle_aant_best_obj_gml_tab_db.$datum_tijd.log
geen_data_log=GEEN_DATA_vgl_alle_aant_best_obj_gml_tab_db.$datum_tijd.log
melding_log=MELDING_vgl_alle_aant_best_obj_gml_tab_db.$datum_tijd.log


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    START_SH_vergelijk_alle_gml_db.sh                 *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT_BGT                                      *"
# "*                                                                             *"
# "* Module :                  Verwerving BGT                                    *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :                                                        *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    Start vergelijking alle equivalente entiteiten    *"
# "*                           het aantal features in objectklasse in bestand    *"
# "*                           met aantal rijen in BGT_tabel, en maak daarvan    *"
# "*                           ��n logbestand voor alle entiteiten.              *"
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
# "* Raymond Young, IV-BI      06-06-2016   1.00.0   RC1: verbetering afhandelen *"
# "*                                                 fouten onder Ubunt-Linux    *"
# "* Raymond Young, IV-BI      14-06-2016   1.00.0   RC1: wijz. stand.loc. GML   *"
# "* Raymond Young, IV-BI      14-07-2016   1.00.0   RC1: wijz. voorbeeldaanroep *"
# "* Raymond Young, IV-BI      19-07-2016   1.00.0   RC1: - parameters -> log    *"
# "*                                                      - poortnr -> mld_log   *"
# "*                                                      - wijz. parameternamen *"
# "* Raymond Young, IV-BI      05-08-2016   1.00.0   RC1: interpr. met bash      *"
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


# Start dit script als volgt, waarbij voor parameters (<HOOFDLETTERS>, <LOCATIE_GML> etc.) juiste waarden dienen te worden meegegeven:
#
# sh START_SH_vergelijk_alle_gml_db.sh <LOCATIE_GML> <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: START_SH_vergelijk_alle_gml_db.sh ./GML/ 85.222.225.45 bgt_dev 8080 bgt
# (of uiteraard andere locatie- of database-gegevens)
# Als niet alle parameters 1 t/m 5 zijn gevuld, krijgen die een standaardwaarde (zie hieronder).


echo
echo "*******************************************************************************"
echo "* Start script $0 ..."
echo "* Start voor alle equivalente entiteiten vergelijking tussen                  *"
echo "* het aantal features in objectklasse in bestand                              *"
echo "* met aantal rijen in BGT_tabel,                                              *"
echo "* en maak daarvan ��n logbestand voor alle entiteiten.                        *"
echo "*******************************************************************************"
echo

if test "$#" -ne "5"
  then
    # als niet ALLE 5 (!) parameters 1 t/m 5 zijn gevuld,
	# worden GML-bestanden gezocht op locatie <huidige directory>/GML/
	# en wordt ontwikkel-BGT-database DataPunt benaderd.
    # Vul parameters met standaardwaarden ...
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

# verwijder oude tussenresultaten (geef_aantal_*.log en tel_*.log) vorige vergelijking GML en DB
rm -f log/tel_*.log
rm -f log/geef_*.log
# Let op: logbestanden VGL_ALLE_AANT-, VERSCHIL-, GEEN_DATA- en MELDING_best_obj_gml_tab_db.datum_tijd.log blijven beschikbaar.

sh vgl_alle_aant_best_obj_gml_tab_db.sh $locatie_GML $db_server $database $db_port $db_user 2>&1 | tee log/$logbestand

cat log/$logbestand | fgrep -e 'VERSCHIL' -e 'Verschil' -e '--' -e 'Parameter' > log/$verschil_log
cat log/$verschil_log | fgrep 'VERSCHIL' > log/$verschil_log.tmp.log
if test -s log/$verschil_log.tmp.log 
then
   echo 'LET OP! Voor de volgende entiteiten zijn verschillen gesignaleerd :'
   echo
   cat log/$verschil_log
else
   rm -f log/$verschil_log
fi
rm -f log/$verschil_log.tmp.log

cat log/$logbestand | fgrep -e ':                                           ;' -e Verschil -e '--' -e 'Parameter' > log/$geen_data_log
cat log/$geen_data_log | fgrep ':                                           ;' > log/$geen_data_log.tmp.log
if test -s log/$geen_data_log.tmp.log 
then
   echo
   echo 'LET OP! De volgende entiteiten konden niet worden vergeleken (geen data) :'
   echo
   cat log/$geen_data_log
else
   rm -f log/$geen_data_log
fi
rm -f log/$geen_data_log.tmp.log

# echo
# echo Bovenstaande geeft een logbestand met daarin voor alle equivalente entiteiten de volgende uitvoer:
# echo de naam,aantal features in GML-objectklasse, aantal rijen in tabel,
# echo eventueel de tekst 'VERSCHIL : ' en $verschilaantal.
# echo Een grotendeels lege regel zonder aantallen of verschillen
# echo duidt of ontbreken data en dus op onmogelijkheid vergelijking.
# echo

# schrijf meldingen in tellingen (gml-bestand of tabel afwezig) of logbestanden naar meldingen-logbestand
cat log/$logbestand | fgrep -e '--' -e 'Parameter' > log/$melding_log
echo >> log/$melding_log
echo 'Meldingen bij telling in GML-bestanden :' >> log/$melding_log
echo >> log/$melding_log
cat log/tel_bestand_*.log | fgrep -e 'Unable' -e 'ERROR' -e 'FAILURE' >> log/$melding_log
echo >> log/$melding_log
echo 'Meldingen bij telling in DB-tabellen :' >> log/$melding_log
echo >> log/$melding_log
cat log/tel_tabel_*.log | fgrep -e 'ERROR' -e 'FAILURE' -e "$db_port" >> log/$melding_log
echo >> log/$melding_log
echo 'Overige meldingen in log-bestanden :'  >> log/$melding_log
echo >> log/$melding_log
cat log/$logbestand | fgrep -e 'ERROR' -e 'FAILURE' >> log/$melding_log
cat log/$verschil_log | fgrep -e 'ERROR' -e 'FAILURE' >> log/$melding_log
cat log/$geen_data_log | fgrep -e 'ERROR' -e 'FAILURE' >> log/$melding_log

# verwijder meldingen-logbestand als het geen meldingen bevat
cat log/$melding_log | fgrep -e 'Unable' -e 'ERROR' > log/$melding_log.tmp.log
if test ! -s log/$melding_log.tmp.log
then
   rm -f log/$melding_log
fi
rm -f log/$melding_log.tmp.log

echo

# verwijder tussenresultaten (geef_aantal_*.log en tel_*.log) van deze vergelijking GML en DB
rm -f log/tel_*.log
rm -f log/geef_*.log
# Let op: logbestanden VGL_ALLE_AANT-, VERSCHIL-, GEEN_DATA- en MELDING_best_obj_gml_tab_db.datum_tijd.log blijven beschikbaar.

echo
echo "*******************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met voor alle equivalente entiteiten                                  *"
echo "* vergelijken aantal features GML-best. met rijen tabel DB.                   *"
echo "*******************************************************************************"
echo
