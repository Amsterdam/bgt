
--\qecho
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Naam :                    create_tbl_imgeo_controle.tel_gml.sql             *"
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
--\qecho "* Doel :                    Aanmaak tabel tel_gml                             *"
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
\qecho "* Aanmaak tabel imgeo_controle.tel_gml ...                                    *"
\qecho "*******************************************************************************"
\qecho

-- Schema: imgeo_controle

-- \pset tuples_only

CREATE TABLE IF NOT EXISTS imgeo_controle.tel_gml
(
  tabelnaam character varying, -- tabelnaam van de gmlobjectklasse
  aantal bigint -- aantal rijen in de gmltabel
) WITHOUT OIDS;

--ALTER TABLE imgeo_controle.tel_gml
--  OWNER TO bgt;
COMMENT ON TABLE imgeo_controle.tel_gml
  IS 'tel_gml wordt een telling van het aantal rijen van de geïmporteerde  gml-tabellen bijgehouden.';
COMMENT ON COLUMN imgeo_controle.tel_gml.tabelnaam IS 'tabelnaam van de gmlobjectklasse';
COMMENT ON COLUMN imgeo_controle.tel_gml.aantal IS 'aantal rijen in de gmltabel';


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak tabel imgeo_controle.tel_gml.                             *"
\qecho "*******************************************************************************"
\qecho
