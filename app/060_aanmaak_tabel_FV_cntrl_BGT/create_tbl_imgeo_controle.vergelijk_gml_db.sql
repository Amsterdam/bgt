
--\qecho
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Naam :                    create_tbl_imgeo_controle.vergelijk_gml_db.sql    *"
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
--\qecho "* Doel :                    Aanmaak tabel vergelijk_gml_db                    *"
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
\qecho "* Aanmaak tabel imgeo_controle.vergelijk_gml_db ...                           *"
\qecho "*******************************************************************************"
\qecho

-- Schema: imgeo_controle

-- \pset tuples_only

CREATE TABLE IF NOT EXISTS imgeo_controle.vergelijk_gml_db
(
  tabelnaam character varying,
  aantal_gml bigint, -- aantal rijen van gml tabellen in dbase
  aantal_db bigint, -- aantal rijen van imgeo-tabellen in dbase
  verschil bigint -- verschil gml-tabellen met imgeo-tabellen in dbase
) WITHOUT OIDS;

--ALTER TABLE imgeo_controle.vergelijk_gml_db
--  OWNER TO bgt;
COMMENT ON TABLE imgeo_controle.vergelijk_gml_db
  IS 'vergelijk_gml_db bevat een vergelijking van de telling in de gmltabellen met de imgeo-tabellen in de dbase';
COMMENT ON COLUMN imgeo_controle.vergelijk_gml_db.aantal_gml IS 'aantal rijen van gml tabellen in dbase';
COMMENT ON COLUMN imgeo_controle.vergelijk_gml_db.aantal_db IS 'aantal rijen van imgeo-tabellen in dbase';
COMMENT ON COLUMN imgeo_controle.vergelijk_gml_db.verschil IS 'verschil gml-tabellen met imgeo-tabellen in dbase';


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak tabel imgeo_controle.vergelijk_gml_db.                    *"
\qecho "*******************************************************************************"
\qecho
