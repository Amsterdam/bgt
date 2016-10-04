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


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    geef_aantal_tabel_db.sh                           *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT_BGT                                      *"
# "*                                                                             *"
# "* Module :                  Verwerving BGT                                    *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      vergelijk_aantal_bestand_object_gml_tabel_db.sh   *"
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
# "* Raymond Young, IV-BI      31-05-2016   1.00.0   RC1: aanroep scripts met sh *"
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


# Start dit shellscript geef_aantal_tabel_db.sh door:
#
# sh geef_aantal_tabel_db.sh <TABEL> <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh geef_aantal_tabel_db.sh bgt_put 85.222.225.45 bgt_dev 8080 bgt
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

# Maak gebruik van script tel_tabel_db.sh om uitvoer
# (zelfde als logbestand) in variabele te zetten en op scherm, en daaruit
# het aantal rijen in tabel te halen m.b.v. onderstaande 2 opdrachten:

tel_tabel_db=$(sh tel_tabel_db.sh $tabel $db_server $database $db_port $db_user)

# In de uitvoer van tel_tabel_db.sh, en dus ook in variabele tel_tabel_db
# staat op positie zoveel vanaf het begin het aantal rijen in tabel. In plaats van deze positie te bepalen,
# kunnen we ook aannemen dat aantal op laatste regel staat en daaruit het getal filteren d.m.v.:

echo "$tel_tabel_db" | tail -1l | grep -o '[0-9]*'

# Bovenstaande geeft de volgende uitvoer (aantal rijen in tabel in database):
# 12852 (nu zonder voorloopspaties)
#

# valt dus mee te rekenen rekenen m.b.v. expr
#


# ""
# "*******************************************************************************"
# "* Klaar met opvragen aantal rijen in tabel in database ...                    *"
# "*******************************************************************************"
# "" 
