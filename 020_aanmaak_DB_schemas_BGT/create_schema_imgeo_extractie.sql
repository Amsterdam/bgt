--
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Naam :                    create_schema_imgeo_extractie.sql                 *"
-- "*                                                                             *"
-- "* Systeem :                 DATAPUNT                                          *"
-- "*                                                                             *"
-- "* Module :                  BGT (Verwerving)                                  *"
-- "*                                                                             *"
-- "* Schema / Gegevensstroom : imgeo_extractie / BGT                             *"
-- "*                                                                             *"
-- "* Aangeroepen vanuit :      START_SQL_schema.sql                              *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Doel :                    SQL-scripts voor aanmaken schema: imgeo_extractie *"
-- "*                           ten behoeve van BGT imgeo views                   *"
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
-- "* Nico de Graaff, BI        06-06-2016   1.00.0   RC1: initiële aanmaak       *"
-- "* Ron van Barneveld, IV-BI  22-07-2016   1.00.0   RC1: ombouwen voor aanmaak  *"
-- "*                                                 schemas                     *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Parameter 1 :             server                database-server BGT-gegevs  *"
-- "* Parameter 2 :             database              database BGT-gegevens       *"
-- "* Parameter 3 :             port                  poort naar database-server  *"
-- "* Parameter 4 :             username              gebruiker t.b.v. BGT        *"
-- "*                                                                             *"
-- "*******************************************************************************"
--


\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaken schema imgeo_extractie tbv extractie BGT-data ...                  *"
\qecho "*******************************************************************************"
\qecho

-- Schema: imgeo_extractie

DROP SCHEMA imgeo_extractie;

CREATE SCHEMA IF NOT EXISTS imgeo_extractie
  AUTHORIZATION bgt;
--
--
\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaken schema imgeo_extractie.                                  *"
\qecho "*******************************************************************************"
\qecho
