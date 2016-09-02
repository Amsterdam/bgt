--
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Naam :                    create_schema_imgeo.sql                           *"
-- "*                                                                             *"
-- "* Systeem :                 DATAPUNT                                          *"
-- "*                                                                             *"
-- "* Module :                  BGT (Verwerving)                                  *"
-- "*                                                                             *"
-- "* Schema / Gegevensstroom : imgeo / BGT                                       *"
-- "*                                                                             *"
-- "* Aangeroepen vanuit :      create_schema_imgeo.sh                            *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Doel :                    SQL-scripts voor aanmaken schema: imgeo           *"
-- "*                           ten behoeve van BGT imgeo-tabellen                *"
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
\qecho "* Aanmaken schema imgeo tbv BGT_tabellen ...                                  *"
\qecho "*******************************************************************************"
\qecho

-- Schema: imgeo

DROP SCHEMA IF EXISTS imgeo CASCADE;

CREATE SCHEMA IF NOT EXISTS imgeo
  AUTHORIZATION bgt;
--
--
\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaken schema imgeo.                                            *"
\qecho "*******************************************************************************"
\qecho
