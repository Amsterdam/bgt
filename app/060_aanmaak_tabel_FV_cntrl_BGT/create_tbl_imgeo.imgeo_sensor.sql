
--\qecho
--\qecho "*******************************************************************************"
--\qecho "*                                                                             *"
--\qecho "* Naam :                    create_tbl_imgeo.imgeo_sensor.sql                 *"
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
--\qecho "* Doel :                    Aanmaak tabel imgeo_sensor in                     *"
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
--\qecho "* Raymond Young, IV-BI      01-08-2016   1.00.0   RC1: standaardiseren        *"
--\qecho "*                                                 commentaar                  *"
--\qecho "*                                                                             *"
--\qecho "*******************************************************************************"


\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak tabel imgeo.imgeo_sensor ...                                        *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo

-- \pset tuples_only

-- DROP TABLE imgeo.imgeo_sensor;

CREATE TABLE IF NOT EXISTS imgeo.imgeo_sensor
(
  identificatie_namespace character varying(8),
  identificatie_lokaalid character varying(38),
  objectbegintijd date,
  objecteindtijd date,
  tijdstipregistratie timestamp without time zone,
  eindregistratie timestamp without time zone,
  lv_publicatiedatum timestamp without time zone,
  bronhouder character varying(40),
  inonderzoek character varying(1),
  relatievehoogteligging smallint,
  bgt_status character varying(8),
  plus_status character varying(8),
  bgt_type character varying(200),
  plus_type character varying(200),
  geometrie geometry(Geometry,28992)
) WITHOUT OIDS;

--ALTER TABLE imgeo.imgeo_sensor
--  OWNER TO bgt;

  
\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak tabel imgeo.imgeo_sensor.                                 *"
\qecho "*******************************************************************************"
\qecho
