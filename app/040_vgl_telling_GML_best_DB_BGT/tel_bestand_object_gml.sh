#!/bin/bash

GML=$1
object=$2
locatie_GML=$3

datum_tijd=$(date +"%Y%m%d_%H%M%S")
logbestand=tel_bestand_object_gml.$GML.$object.$datum_tijd.log


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    tel_bestand_object_gml.sh                         *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT_BGT                                      *"
# "*                                                                             *"
# "* Module :                  Verwerving BGT                                    *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      geef_aantal_bestand_object_gml.sh                 *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    Shellscript voor m.b.v. OGR-info opvragen         *"
# "*                           aantal features in objectklasse in GML-bestand    *"
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
# "* Raymond Young, IV-BI      14-06-2016   1.00.0   RC1: wijz. stand.loc. GML   *"
# "* Raymond Young, IV-BI      19-07-2016   1.00.0   RC1: - wijz. voorb.aanroep  *"
# "*                                                      - wijz. parameternamen *"
# "* Raymond Young, IV-BI      05-08-2016   1.00.0   RC1: interpr. met bash      *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Parameter 1 :             GML                   GML-bestand met BGT-gegevs  *"
# "* Parameter 2 :             object                objectlaag in GML-bestand   *"
# "* Parameter 3 :             locatie_GML           locatie GML-bestand         *"
# "*                                                                             *"
# "*******************************************************************************"
# ""


# Start dit shellscript tel_bestand_object_gml.sh door:
#
# sh tel_bestand_object_gml.sh <GML> <OBJECT> <LOCATIE_GML>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh tel_bestand_object_gml.sh bgt_put.gml put ./GML/
# (of uiteraard andere bestands- en laagnamen en locatie))
# Als parameter 3 niet is meegegeven, krijgt die een standaardwaarde (zie hieronder).


# ""
# "*******************************************************************************"
# "* tellen aantal features in objectklasse ...                                  *"
# "*******************************************************************************"
# "" 

if test "$#" -eq "2"
  then
    # als parameter 3 niet is gevuld,
	# wordt aangenomen dat GML-bestanden in huidige directory staan.
    # echo 'test $# -eq 2' : Vul variabelen met standaardwaarden ...
    GML=$1
    object=$2
    locatie_GML='./GML/'
fi

ogrinfo -q $locatie_GML$GML -sql "select count(*) from $object" 2>&1 | tee log/$logbestand

# Bovenstaande geeft de volgende uitvoer:
# Layer name: put
# OGRFeature(put):0
#   COUNT_* (Integer) = 308
#

# Ander shellscript geef_aantal_bestand_object_gml.sh maakt weer gebruik
# van dit script tel_bestand_object_gml.sh
# om uit bovenstaande uitvoer alleen het aantal terug te geven:
# 308


# ""
# "*******************************************************************************"
# "* Klaar met tellen aantal features in objectklasse ...                        *"
# "*******************************************************************************"
# "" 
