
--\qecho
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Naam :                    create_tbl_imgeo_controle.mapping_gml_db.sql      *"
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
--\qecho "* Doel :                    Aanmaak tabel mapping_gml_db                      *"
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
--\qecho "* Raymond Young, IV-BI      26-09-2016   1.00.0   RC1: toevoegen kolommen     *"
--\qecho "*                                                 gmlbestand,shpview,dgnview  *"
--\qecho "* Raymond Young, IV-BI      27-09-2016   1.00.0   RC1: vervangen kolommen     *"
--\qecho "*                                                 shpview,dgnview door        *"
--\qecho "*                                                 een extractieview           *"
--\qecho "*                                                                             *"
--\qecho "*******************************************************************************"


\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak tabel imgeo_controle.mapping_gml_db ...                             *"
\qecho "*******************************************************************************"
\qecho

-- Schema: imgeo_controle

-- \pset tuples_only

CREATE TABLE imgeo_controle.mapping_gml_db
(
  gmlbestand character varying, -- gmlbestand
  gmlnaam character varying, -- gml_objectklasse in gmlbestand
  dbnaam character varying, -- db objectklasse in bgt imgeo-tabel.
  extractieview character varying -- db extractieview in bgt imgeo_extractie.
)
WITH (
  OIDS=FALSE
);

ALTER TABLE imgeo_controle.mapping_gml_db
  OWNER TO bgt;
COMMENT ON TABLE imgeo_controle.mapping_gml_db
  IS 'mapping_gml-db tabel met daarin de mapping van de gml-bestand, -objectklasse, db-objectklasse en Shape- en DGN-extractieview.';
COMMENT ON COLUMN imgeo_controle.mapping_gml_db.gmlnaam IS 'gml_objectklasse in  gmlbestand';
COMMENT ON COLUMN imgeo_controle.mapping_gml_db.dbnaam IS 'db objectklasse in bgt imgeo-tabel.';
COMMENT ON COLUMN imgeo_controle.mapping_gml_db.extractieview IS 'db extractieview in bgt imgeo_extractie.';


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak tabel imgeo_controle.mapping_gml_db.                      *"
\qecho "*******************************************************************************"
\qecho
