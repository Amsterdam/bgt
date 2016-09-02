#!/usr/bin/env bash
echo ""
echo "*******************************************************************************"
echo "*                                                                             *"
echo "* Naam :                    START_SH_download_alle_BGT.sh                     *"
echo "*                                                                             *"
echo "* Systeem :                 DATAPUNT_BGT                                      *"
echo "*                                                                             *"
echo "* Module :                  Verwerving BGT                                    *"
echo "*                                                                             *"
echo "* Schema / Gegevensstroom : BGT                                               *"
echo "*                                                                             *"
echo "* Aangeroepen vanuit :                                                        *"
echo "*                                                                             *"
echo "*******************************************************************************"
echo "*                                                                             *"
echo "* Doel :                    Shellscript voor starten van downloadscript       *"
echo "*                           alle BGT-gegevens                                 *"
echo "*                                                                             *"
echo "*******************************************************************************"
echo "*                                                                             *"
echo "* DATAPUNT-BGT versienr :   0.0.1                                             *"
echo "*                                                                             *"
echo "*******************************************************************************"
echo "*                                                                             *"
echo "* Wijzigingsgeschiedenis :                                                    *"
echo "*                                                                             *"
echo "* auteur                    datum        versie   wijziging                   *"
echo "* -----------------------   ----------   ------   --------------------------- *"
echo "* Raymond Young, IV-BI      23-05-2017   0.0.1    RC1: initiële aanmaak       *"
echo "* Raymond Young, IV-BI      25-07-2017   0.0.1    RC1: naam script gewijzigd  *"
echo "*                                                                             *"
echo "*******************************************************************************"
echo "*                                                                             *"
echo "* Parameter 0 :                                                               *"
echo "*                                                                             *"
echo "*******************************************************************************"
echo ""

echo ""
echo "*******************************************************************************"
echo "* Downloaden alle BGT-gegevens ...                                            *"
echo "*******************************************************************************"
echo "" 

huidige_dir=$(pwd)
# echo $huidige_dir
# read -p "pauze, tik wat dan ook om verder te gaan ... : " willekeurige_toets

# pwd | $huidige_dir/log/huidige_dir.log

sh $huidige_dir/download_alle_BGT.sh 2>&1 | tee $huidige_dir/log/download_alle_BGT.log

read -p "pauze, tik wat dan ook om verder te gaan ... : " willekeurige_toets
echo ""
echo "*******************************************************************************"
echo "* Klaar met downloaden alle BGT-gegevens.                                     *"
echo "*******************************************************************************"
echo ""
read -p "pauze, tik wat dan ook om verder te gaan ... : " willekeurige_toets
