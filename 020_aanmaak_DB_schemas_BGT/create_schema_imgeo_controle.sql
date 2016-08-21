--
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Naam :                    create_schema_imgeo_controle.sql                  *"
-- "*                                                                             *"
-- "* Systeem :                 DATAPUNT                                          *"
-- "*                                                                             *"
-- "* Module :                  BGT (Verwerving)                                  *"
-- "*                                                                             *"
-- "* Schema / Gegevensstroom : imgeo_controle / BGT                              *"
-- "*                                                                             *"
-- "* Aangeroepen vanuit :      START_SQL_schema.sql                              *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Doel :                    SQL-scripts voor aanmaken schema: imgeo_controle  *"
-- "*                           ten behoeve van controle-tabellen                 *"
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
-- "* Raymond Young, IV-BI      25-07-2016   1.00.0   RC1: standaardiseren        *"
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
\qecho "* Aanmaken schema imgeo_controle tbv controle BGT-gegevens ...                *"
\qecho "*******************************************************************************"
\qecho

-- Schema: imgeo_controle

-- DROP SCHEMA imgeo_controle;

CREATE SCHEMA imgeo_controle
  AUTHORIZATION bgt;
--
--
\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaken schema imgeo_controle.                                   *"
\qecho "*******************************************************************************"
\qecho
