-- "*
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Naam :                    create_schema_imgeo_gml.sql                       *"
-- "*                                                                             *"
-- "* Systeem :                 DATAPUNT                                          *"
-- "*                                                                             *"
-- "* Module :                  BGT (Verwerving)                                  *"
-- "*                                                                             *"
-- "* Schema / Gegevensstroom : imgeo_gml / BGT                                   *"
-- "*                                                                             *"
-- "* Aangeroepen vanuit :      START_SQL_schema.sql                              *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Doel :                    Aanmaak schema imgeo_gml                          *"
-- "*                           ten behoeve van inlezen GML-gegevens BGT.         *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* DATAPUNT-BGT-versienr :   1.00.0                                            *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Wijzigingsgeschiedenis :                                                    *"
-- "*                                                                             *"
-- "* auteur                    datum        versie   wijziging                   *"
-- "* -----------------------   ----------   ------   --------------------------- "*
-- "* Nico de Graaff, BI        04-04-2016   1.00.0   RC1: initiële aanmaak       *"
-- "* Ron van Barneveld, IV-BI  22-07-2016   1.00.0   RC1: ombouwen voor aanmaak  *"
-- "*                                                 schemas                     *"
-- "*                                                                             *"
-- "*******************************************************************************"


\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaken schema imgeo_gml ten behoeve van inlezen GML-gegevens BGT ...      *"
\qecho "*******************************************************************************"
\qecho
--
--
-- Schema: imgeo_gml

DROP SCHEMA IF EXISTS imgeo_gml CASCADE;

CREATE SCHEMA IF NOT EXISTS imgeo_gml;
--
--
\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaken schema imgeo_gml.                                        *"
\qecho "*******************************************************************************"
\qecho
