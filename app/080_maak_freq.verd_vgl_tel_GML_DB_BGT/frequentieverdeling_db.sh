#!/bin/bash

# positionele parameters voor toegang database
db_server=$1
database=$2
db_port=$3
db_user=$4
# wachtwoord kan niet worden meegegegeven;
# aangenomen wordt dat dat wordt gezet in bestand <Linux-gebruiker>/.pgpass.
# (let op de rechten op .pgpass ALLEEN user Root mag read/write rechten hebben.)
# (als dit niet is gedaan, moet het wachtwoord met de hand worden ingetikt
# voor ieder keer dat met een script de database wordt benaderd)
# BGT-database moet openstaan voor benadering van buitenaf;
# dit moet zijn geregeld in bestand pg_hba.conf.
# Zie voorbeeldbestandjes in submapje configuratie.

# Hieronder t.b.v. de logging een aantal standaardvariabelen uit de Linux-omgeving:
whoami=$(whoami)   					# whoami - print effective userid
who_m=$(who -m)    					# who - show who is logged on, optie: -m     only hostname and user associated with stdin
working_dir=$(pwd) 					# pwd - print name of current/working directory
datum_tijd=$(date +"%Y%m%d_%H%M%S") # date - print or set the system date and time

logbestand=${working_dir}/log/frequentieverdeling_db.${datum_tijd}.log
sql_script=${working_dir}/log/frequentieverdeling_db.${datum_tijd}.sql


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    frequentieverdeling_db.sh                         *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT                                          *"
# "*                                                                             *"
# "* Module :                  BGT (Verwerving)                                  *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      START_SH_frequentieverdeling_db.sh                *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    SQL-scripts aanmaken en aftrappen voor            *"
# "*                           maken frequentieverdeling BGT-/IMGEO-tabellen     *"
# "*                           in schema IMGEO                                   *"
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
# "* Ron van Barneveld, IV-BI  13-06-2016   1.00.0   RC1: initiële aanmaak       *"
# "* Ron van Barneveld, IV-BI  14-07-2016   1.00.0   RC1: nieuw schema en tabel  *"
# "* Raymond Young, IV-BI      04-08-2016   1.00.0   RC1: - splits START_SH en   *"
# "*                                                        aanmaak-script.SH    *"
# "*                                                      - parameters -> log    *"
# "*                                                      - interpr. met bash    *"
# "* Raymond Young, IV-BI      15-08-2016   1.00.0   RC1: - wijz. parameternamen *"
# "*                                                      - toevoegen leegmaken  *"
# "*                                                        tabel                *"
# "* Raymond Young, IV-BI      16-08-2016   1.00.0   RC1: trachten gelijkmaken   *"
# "*                                                 te verdelen kolommen GML/DB *"
# "* Raymond Young, IV-BI      30-08-2016   1.00.0   RC1: verwijder uitgecommen- *"
# "*                                                 tarieerde kolomnamen        *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Parameter 1 :             db_server             database-server BGT-gegevs  *"
# "* Parameter 2 :             database              database BGT-gegevens       *"
# "* Parameter 3 :             db_port               poort naar database-server  *"
# "* Parameter 4 :             db_user               gebruiker t.b.v. BGT        *"
# "*                                                                             *"
# "*******************************************************************************"
# ""


# Start dit script als volgt, waarbij voor parameters (<HOOFDLETTERS>, etc.) juiste waarden dienen te worden meegegeven:
#
# sh frequentieverdeling_db.sh <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>  
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: frequentieverdeling_db.sh 10.62.86.35 bgt_dev_local 5433 bgt  --> hiermee wordt de lokale GML aangesproken en de lokale database benaderd.

# Ter info hieronder een voorbeeld van de parameters lokaal op de laptop van RonvB (variabel IP-adres!):
# db_user=bgt       --> default user van de database
# db_server=10.62.86.35 --> dit is het ip-adres van de lokaal database op de laptop (met ipconfig in cmd te achterhalen)  
# db_port=5433          --> dit portnummer is specifiek van de lokale database van Ron van Barneveld.
# database=bgt_dev_local --> databasenaam afhankelijk van lokale naamgeving

# (of uiteraard andere locatie- of database-gegevens)
# Als niet ALLE parameters 1 t/m 4 zijn gevuld, krijgen die een standaardwaarde (zie hieronder).

# Ter info hieronder de parameters op datapunt:
# db_server=85.222.225.45
# database=bgt_dev
# db_port=8080
# db_user=bgt


echo
echo "*******************************************************************************"
echo "* Start script $0 ..."
echo "* Maken frequentieverdeling BGT-/IMGEO-tabellen in schema IMGEO ...           *"
echo "*******************************************************************************"
echo

# Controle of parameters zijn meegegeven:
if test "$#" -ne "4"
  then
    # als niet ALLE 4 (!) parameters 1 t/m 4 zijn gevuld,
	# wordt ontwikkel-BGT-database DataPunt benaderd.
    # Vul variabelen met standaardwaarden ...
    
    if test "$1" = ""
      then
        db_server='85.222.225.45'
    fi
	if test "$2" = ""
      then
        database='bgt_dev'
    fi
    if test "$3" = ""
      then
        db_port='8080'
    fi
    if test "$4" = ""
      then
        db_user='bgt'
    fi
fi

echo
echo "-------------------------------------------------------------------------------"
echo "ParameterX: os_user     = ${whoami} / ${who_m}"
echo "ParameterY: working_dir = ${working_dir}"
echo "ParameterZ: datum_tijd  = ${datum_tijd}"
echo "Parameter0: script      = $0"
echo "Parameter1: db_server   = ${db_server}"
echo "Parameter2: database    = ${database}"
echo "Parameter3: db_port     = ${db_port}"
echo "Parameter4: db_user     = ${db_user}"
echo "-------------------------------------------------------------------------------"
echo

echo
echo "Leeg tabel FREQUENTIEVERDELING_DB in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "TRUNCATE TABLE imgeo_controle.FREQUENTIEVERDELING_DB;"

echo
echo "Genereer SQL-script voor vullen tabel FREQUENTIEVERDELING_DB in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -t -c "select 'insert into imgeo_controle.frequentieverdeling_db (select ' || chr(39) || table_name || chr(39) || ' as tabelnaam,' || chr(39) || column_name || chr(39) || ' as kolomnaam, ' || column_name || ', count (' || column_name || ') as aantal from ' || table_schema || '.' || table_name || ' group by ' || column_name || ' order by ' || column_name || ', aantal );' as smt
FROM information_schema.columns
where table_schema='imgeo'
and( table_name like 'imgeo%' or table_name like 'bgt%')
and column_name not in (
  'bgt_status'
, 'eindregistratie'
, 'geometrie'
, 'hnr_label_hoek'
, 'hnr_label_tekst'
, 'id_bagvbohoogste_huisnummer'
, 'id_bagvbolaagste_huisnummer'
, 'identificatie_lokaalid'
, 'identificatie_namespace'
, 'identificatiebagopr'
, 'identificatiebagpnd'
--, 'inonderzoek'
, 'lv_publicatiedatum'
, 'objectbegintijd'
, 'objecteindtijd'
-- , 'openbareruimtetype'
, 'opr_label_hoek'
, 'opr_label_tekst'
, 'plus_status'
, 'relatievehoogteligging'
, 'tijdstipregistratie'
)
order by table_schema, table_name, column_name;" 2>&1 | tee ${sql_script}

# Bovenstaande geeft de volgende uitvoer in SQL-script: (insert-opdrachten met aantal attribuutwaarden per attribuut van alle bgt-object_tabel in bgt_database):
# bijvoorbeeld: insert into imgeo_controle.frequentieverdeling_db (select 'bgt_begroeidterreindeel' as tabelnaam,'bgt_fysiekvoorkomen' as kolomnaam,bgt_fysiekvoorkomen ,count (bgt_fysiekvoorkomen) from imgeo.bgt_begroeidterreindeel group by bgt_fysiekvoorkomen order by bgt_fysiekvoorkomen );  
# enzovoorts, gevolgd door een COMMIT;

echo
echo "Voer SQL-script uit voor vullen tabel FREQUENTIEVERDELING_DB in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -f ${sql_script}

# Bovenstaande geeft de volgende uitvoer in tabel imgeo_controle.frequentieverdeling_db: frequentieverdelingen per attribuut per BGT-/IMGEO-tabel (= objectklasse) in IMGEO-schema in BGT-database


echo
echo "*******************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met maken frequentieverdeling BGT-/IMGEO-tabellen in schema IMGEO.    *"
echo "*******************************************************************************"
echo
