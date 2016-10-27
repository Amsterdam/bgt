#!/bin/bash

GML=$1
object=$2
locatie_GML=$3

datum_tijd=$(date +"%Y%m%d_%H%M%S")

# Start dit shellscript geef_aantal_bestand_object_gml.sh door:
#
# sh geef_aantal_bestand_object_gml.sh <GML> <OBJECT> <LOCATIE_GML>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh geef_aantal_bestand_object_gml.sh bgt_put.gml put ./GML/
# (of uiteraard andere bestands- en laagnamen en locatie)
# Als parameter 3 niet is meegegeven, krijgt die een standaardwaarde (zie hieronder).


# ""
# "*******************************************************************************"
# "* opvragen aantal features in objectklasse ...                                *"
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

# Maak gebruik van script tel_bestand_object_gml.sh om uitvoer
# (zelfde als logbestand) in variabele te zetten en op scherm, en daaruit
# het aantal features in objectklasse te halen m.b.v. onderstaande 2 opdrachten:

tel_bestand_object=$(sh tel_bestand_object_gml.sh $GML $object $locatie_GML)

# In de uitvoer van tel_bestand_object_gml.sh, en dus ook in variabele tel_bestand_object
# staat op positie zoveel vanaf het begin het aantal features in objectklasse. In plaats van deze positie te bepalen,
# kunnen we ook aannemen dat aantal op laatste regel staat en daaruit het getal filteren d.m.v.:

echo "$tel_bestand_object" | tail -1l | grep -o '[0-9]*'

# Bovenstaande geeft de volgende uitvoer (aantal features in objectklasse van type laag in bestand):
# 308
#

# valt mee te rekenen rekenen m.b.v. expr
#


# ""
# "*******************************************************************************"
# "* Klaar met opvragen aantal features in objectklasse ...                      *"
# "*******************************************************************************"
# "" 
