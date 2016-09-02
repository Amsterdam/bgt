#!/usr/bin/env bash
#echo ""
#echo "*******************************************************************************"
#echo "*                                                                             *"
#echo "* Naam :                    download_alle_BGT.sh                              *"
#echo "*                                                                             *"
#echo "* Systeem :                 DATAPUNT_BGT                                      *"
#echo "*                                                                             *"
#echo "* Module :                  Verwerving BGT                                    *"
#echo "*                                                                             *"
#echo "* Schema / Gegevensstroom : BGT                                               *"
#echo "*                                                                             *"
#echo "* Aangeroepen vanuit :      Start_download_alle_BGT.sh                        *"
#echo "*                                                                             *"
#echo "*******************************************************************************"
#echo "*                                                                             *"
#echo "* Doel :                    Shellscript voor downloaden alle BGT-gegevens     *"
#echo "*                                                                             *"
#echo "*******************************************************************************"
#echo "*                                                                             *"
#echo "* DATAPUNT-BGT-versienr :   1.00.0                                            *"
#echo "*                                                                             *"
#echo "*******************************************************************************"
#echo "*                                                                             *"
#echo "* Wijzigingsgeschiedenis :                                                    *"
#echo "*                                                                             *"
#echo "* auteur                    datum        versie   wijziging                   *"
#echo "* -----------------------   ----------   ------   --------------------------- *"
#echo "* Raymond Young, IV-BI      23-05-2017   1.00.0   RC1: initiele aanmaak       *"
#echo "*                                                                             *"
#echo "*******************************************************************************"
#echo ""

echo ""
echo "*******************************************************************************"
echo "* Downloaden alle BGT-gegevens ...                                            *"
echo "*******************************************************************************"
echo "" 

datum_tijd=$(date +"%Y%m%d_%H%M%S")
echo "datum_tijd : " $datum_tijd
echo "" 

# Instellen downloadparameters
einddatum=$(date +"%d-%m-%Y")
uitvoer=/data/extract_BGT_$datum_tijd.zip

echo "einddatum : " $einddatum
echo "uitvoer   : " $uitvoer
	
echo ""
echo "voer niet-interactief wget-commando uit (alle kaartbladen, zonder plaatsbepalingspunten, zonder historie, einddatum vandaag) ... "
echo ""
wget -q -O "$uitvoer"  "https://www.pdok.nl/download/service/extract.zip?extractset=citygml&tiles=%7B%22layers%22%3A%5B%7B%22aggregateLevel%22%3A0%2C%22codes%22%3A%5B38519%2C38690%2C38517%2C38495%2C38666%2C38688%2C38516%2C38494%2C38664%2C38665%2C38668%2C38669%2C38493%2C38492%2C38489%2C38488%2C38477%2C38476%2C38473%2C38472%2C38429%2C38423%2C38421%2C38079%2C38077%2C38076%2C38070%2C38071%2C38114%2C38115%2C38113%2C38116%2C38094%2C38092%2C38086%2C38087%2C38098%2C38099%2C38102%2C38103%2C38101%2C38272%2C38273%2C38275%2C38278%2C38279%2C38285%2C38296%2C38297%2C38299%2C38321%2C38323%2C38329%2C38331%2C38673%2C38675%2C38674%2C38680%2C38663%2C38662%2C38659%2C38658%2C38487%2C38486%2C38483%2C38482%2C38471%2C38470%2C38468%2C38469%2C38465%2C38467%2C38466%2C38464%2C38122%2C38120%2C38121%2C38123%2C38126%2C38124%2C38118%2C38127%2C38125%2C38119%2C38480%2C38138%2C38136%2C38130%2C38128%2C38117%2C38481%2C38484%2C38485%2C38656%2C38139%2C38142%2C38143%2C38314%2C38137%2C38140%2C38141%2C38312%2C38131%2C38134%2C38135%2C38306%2C38095%2C38093%2C38106%2C38104%2C38129%2C38107%2C38105%2C38132%2C38110%2C38108%2C38133%2C38111%2C38109%2C38304%2C38282%2C38280%2C38274%2C38657%2C38315%2C38313%2C38660%2C38318%2C38316%2C38310%2C38307%2C38661%2C38672%2C38319%2C38330%2C38317%2C38328%2C38311%2C38322%2C38320%2C38298%2C38287%2C38309%2C38305%2C38308%2C38283%2C38286%2C38281%2C38284%5D%7D%5D%7D&excludedtypes=plaatsbepalingspunt&history=false&enddate=$einddatum"

echo "Uitpakken BGT bestand"
unzip -d /data $uitvoer

echo "Verwijderen gedownload bestand"
rm -f $uitvoer

# 2>&1 | tee log/download_alle_BGT_$datum_tijd.log
# echo ""

echo ""
echo "*******************************************************************************"
echo "* Klaar met downloaden en uitpakken alle BGT-gegevens.                        *"
echo "*******************************************************************************"
echo "" 
#read -p "pauze, tik wat dan ook om verder te gaan ... : " willekeurige_toets
