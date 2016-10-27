#!/bin/bash

GML=$1
object=$2
locatie_GML=$3

datum_tijd=$(date +"%Y%m%d_%H%M%S")
logbestand=tel_bestand_object_gml.$GML.$object.$datum_tijd.log


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
