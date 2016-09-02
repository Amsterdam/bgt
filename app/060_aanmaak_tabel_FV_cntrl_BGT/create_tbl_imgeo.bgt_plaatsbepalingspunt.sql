
--\qecho
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Naam :                    create_tbl_imgeo.bgt_plaatsbepalingspunt.sql      *"
--\qecho "*                                                                             *"
--\qecho "* Systeem :                 DATAPUNT                                          *"
--\qecho "*                                                                             *"
--\qecho "* Module :                  BGT (database)                                    *"
--\qecho "*                                                                             *"
--\qecho "* Schema / Gegevensstroom : BGT                                               *"
--\qecho "*                                                                             *"
--\qecho "* Aangeroepen vanuit :      aanmaak_IMGEO_tabellen_BGT.sql                    *"
--\qecho "*                                                                             *"
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Doel :                    Aanmaak tabel bgt_plaatsbepalingspunt in          *"
--\qecho "*                           schema imgeo                                      *"
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
--\qecho "*                                                                             *"
--\qecho "*******************************************************************************"


\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak tabel imgeo.bgt_plaatsbepalingspunt ...                             *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo

-- \pset tuples_only

-- DROP TABLE imgeo.bgt_plaatsbepalingspunt;

CREATE TABLE IF NOT EXISTS imgeo.bgt_plaatsbepalingspunt
(
  identificatie_namespace character varying(8),
  identificatie_lokaalid character varying(38),
  nauwkeurigheid integer,
  datum_inwinning date,
  inwinnende_instantie character varying(40),
  inwinningsmethode_id character varying(40),
  geometrie geometry(Point,28992)
) WITHOUT OIDS;

ALTER TABLE imgeo.bgt_plaatsbepalingspunt
  OWNER TO bgt;

-- Index: imgeo.bgt_plaatsbepalingspunt_geometrie_1465822101622

-- DROP INDEX imgeo.bgt_plaatsbepalingspunt_geometrie_1465822101622;

CREATE INDEX IF NOT EXISTS bgt_plaatsbepalingspunt_geometrie_1465822101622
  ON imgeo.bgt_plaatsbepalingspunt
  USING gist
  (geometrie);


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak tabel imgeo.bgt_plaatsbepalingspunt.                      *"
\qecho "*******************************************************************************"
\qecho
