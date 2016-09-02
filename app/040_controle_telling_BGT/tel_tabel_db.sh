#!/bin/bash

tabel=$1
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
logbestand=tel_tabel_db.$tabel.$datum_tijd.log


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    tel_tabel_db.sh                                   *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT_BGT                                      *"
# "*                                                                             *"
# "* Module :                  Verwerving BGT                                    *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      geef_aantal_tabel_db.sh                           *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    SQL-scripts aftrappen voor telling BGT_tabellen   *"
# "*                           ten behoeve van controle: vergelijking met GML    *"
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
# "* Ron van Barneveld, IV-BI  04-04-2016   1.00.0   RC1: initiële aanmaak       *"
# "* Raymond Young, IV-BI      24-05-2016   1.00.0   RC1: toevoegen parameters   *"
# "* Raymond Young, IV-BI      19-07-2016   1.00.0   RC1: - wijz. voorb.aanroep  *"
# "*                                                      - wijz. parameternamen *"
# "* Raymond Young, IV-BI      05-08-2016   1.00.0   RC1: interpr. met bash      *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Parameter 1 :             tabel                 tabel BGT-gegevens          *"
# "* Parameter 2 :             db_server             database-server BGT-gegevs  *"
# "* Parameter 3 :             database              database BGT-gegevens       *"
# "* Parameter 4 :             db_port               poort naar database-server  *"
# "* Parameter 5 :             db_user               gebruiker t.b.v. BGT        *"
# "*                                                                             *"
# "*******************************************************************************"
# ""


# Start dit shellscript tel_tabel_db.sh door:
#
# sh tel_tabel_db.sh <TABEL> <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh tel_tabel_db.sh bgt_put 85.222.225.45 bgt_dev 8080 bgt
# (of uiteraard andere tabel- of database-gegevens)
# Als parameter 2 t/m 5 niet zijn meegegeven, krijgen die een standaardwaarde (zie hieronder).


# ""
# "*******************************************************************************"
# "* Query aftrappen bevraging imgeo BGT_tabellen ...                            *"
# "*******************************************************************************"
# ""

if test "$#" -eq "1"
  then
    # als parameters 2 t/m 5 niet zijn gevuld, wordt ontwikkel-BGT-database DataPunt benaderd
    # echo 'test $# -eq 1' : Vul variabelen met standaardwaarden ...
    tabel=$1
    db_server='85.222.225.45'
    database='bgt_dev'
    db_port='8080'
    db_user='bgt'
fi

psql -h $db_server -U $db_user -d $database -p $db_port -t -c "SELECT count(*) FROM imgeo.$tabel" 2>&1 | tee log/$logbestand

# Geef aantal rijen in tabel bv imgeo_paal
# Start dit shellscript tel_tabel_db.sh door:
# sh tel_tabel_db.sh <TABEL> <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh tel_tabel_db.sh bgt_put 85.222.225.45 bgt_dev 8080 bgt
# als parameters 2 t/m 5 niet zijn gevuld, wordt ontwikkel-BGT-database DataPunt benaderd

# Bovenstaande geeft de volgende uitvoer (aantal rijen in tabel in database):
#  12852 (inclusief eventueel voorloopspaties)
#

# valt dus nog niet mee te mee te rekenen rekenen m.b.v. expr
#


# ""
# "*******************************************************************************"
# "* Klaar met opvragen aantal rijen in tabel in database ...                    *"
# "*******************************************************************************"
# "" 
