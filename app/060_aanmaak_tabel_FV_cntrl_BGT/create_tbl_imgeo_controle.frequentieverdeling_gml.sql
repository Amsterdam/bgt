
--\qecho
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Naam :                    create_tbl_imgeo_controle.frequentieverdeling_gml *"
--qecho *"                            .sql                                              *"
--\qecho "*                                                                             *"
--\qecho "* Systeem :                 DATAPUNT                                          *"
--\qecho "*                                                                             *"
--\qecho "* Module :                  BGT (database)                                    *"
--\qecho "*                                                                             *"
--\qecho "* Schema / Gegevensstroom : BGT                                               *"
--\qecho "*                                                                             *"
--\qecho "* Aangeroepen vanuit :      aanmaak_IMGEO_controle_tabellen_BGT.sql           *"
--\qecho "*                                                                             *"
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Doel :                    Aanmaak tabel frequentieverdeling_gml             *"
--\qecho "*                           in schema imgeo_controle                          *"
--\qecho "*                                                                             *"
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* DATAPUNT-BGT versienr :   1.00.0                                            *"
--\qecho "*                                                                             *"
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Wijzigingsgeschiedenis :                                                    *"
--\qecho "*                                                                             *"
--\qecho "* auteur                    datum        versie   wijziging                   *"
--\qecho "* -----------------------   ----------   ------   --------------------------- *"
--\qecho "* Ron van Barneveld, IV-BI  23-06-2016   1.00.0   RC1: initiële aanmaak       *"
--\qecho "* Raymond Young, IV-BI      01-08-2016   1.00.0   RC1: standaardiseren        *"
--\qecho "*                                                 commentaar                  *"
--\qecho "*                                                                             *"
--\qecho "*******************************************************************************"


\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak tabel imgeo_controle.frequentieverdeling_gml ...                    *"
\qecho "*******************************************************************************"
\qecho

-- Schema: imgeo_controle

-- \pset tuples_only

CREATE TABLE IF NOT EXISTS imgeo_controle.frequentieverdeling_gml
(
  tabelnaam character varying, -- Tabelnaam van de objectklasse van het gml-bestand.
  kolomnaam character varying, -- Kolomnaam van de attribuut van de objectklasse.
  kolomwaarde character varying,
  aantal bigint
) WITHOUT OIDS;

--ALTER TABLE imgeo_controle.frequentieverdeling_gml
--  OWNER TO bgt;
COMMENT ON TABLE imgeo_controle.frequentieverdeling_gml
  IS 'In tabel frequentieverdeling_gml wordt een telling opgeslagen van het aantal attribuutwaarden per objectklasse van de geïmporteerde gmlbestanden.';
COMMENT ON COLUMN imgeo_controle.frequentieverdeling_gml.tabelnaam IS 'Tabelnaam van de objectklasse van het gml-bestand.';
COMMENT ON COLUMN imgeo_controle.frequentieverdeling_gml.kolomnaam IS 'Kolomnaam van de attribuut van de objectklasse. ';


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak tabel imgeo_controle.frequentieverdeling_gml.             *"
\qecho "*******************************************************************************"
\qecho
