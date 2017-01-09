DROP TABLE IF EXISTS imgeo.imgeo_functioneelgebied CASCADE;
CREATE TABLE imgeo.imgeo_functioneelgebied
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
  naam character varying(200),
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.imgeo_functioneelgebied OWNER TO dbuser;
CREATE INDEX imgeo_functioneelgebied_geometrie_1465822099300 ON imgeo.imgeo_functioneelgebied USING gist (geometrie);


DROP TABLE IF EXISTS imgeo.bgt_plaatsbepalingspunt CASCADE;
CREATE TABLE imgeo.bgt_plaatsbepalingspunt
(
  identificatie_namespace character varying(8),
  identificatie_lokaalid character varying(38),
  nauwkeurigheid integer,
  datum_inwinning date,
  inwinnende_instantie character varying(40),
  inwinningsmethode_id character varying(40),
  geometrie geometry(Point,28992)
);
ALTER TABLE imgeo.bgt_plaatsbepalingspunt OWNER TO dbuser;
CREATE INDEX bgt_plaatsbepalingspunt_geometrie_1465822101622 ON imgeo.bgt_plaatsbepalingspunt USING gist (geometrie);

DROP TABLE IF EXISTS imgeo.imgeo_bord CASCADE;
CREATE TABLE imgeo.imgeo_bord
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
  geometrie geometry(Point,28992)
);
ALTER TABLE imgeo.imgeo_bord OWNER TO dbuser;
CREATE INDEX imgeo_bord_geometrie_1465822102262 ON imgeo.imgeo_bord USING gist (geometrie);

DROP TABLE IF EXISTS imgeo.imgeo_mast CASCADE;
CREATE TABLE imgeo.imgeo_mast
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
  geometrie geometry(Point,28992)
);
ALTER TABLE imgeo.imgeo_mast OWNER TO dbuser;
CREATE INDEX imgeo_mast_geometrie_1465822102262 ON imgeo.imgeo_mast USING gist (geometrie);

DROP TABLE IF EXISTS imgeo.imgeo_sensor CASCADE;
CREATE TABLE imgeo.imgeo_sensor
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
);
ALTER TABLE imgeo.imgeo_sensor OWNER TO dbuser;

DROP TABLE IF EXISTS imgeo_controle.frequentieverdeling_db CASCADE;
CREATE TABLE imgeo_controle.frequentieverdeling_db
(
  tabelnaam character varying, -- tabelnaam bgt imgeo-tabel
  kolomnaam character varying, -- kolomnaam bgt imgeo-tabel
  kolomwaarde character varying,
  aantal bigint
);
ALTER TABLE imgeo_controle.frequentieverdeling_db OWNER TO dbuser;
COMMENT ON TABLE imgeo_controle.frequentieverdeling_db
  IS 'frequentieverdeling_db wordt het aantal attribuutwaarden van de bgt imgeo-tabellen bijgehouden.';
COMMENT ON COLUMN imgeo_controle.frequentieverdeling_db.tabelnaam IS 'tabelnaam bgt imgeo-tabel';
COMMENT ON COLUMN imgeo_controle.frequentieverdeling_db.kolomnaam IS 'kolomnaam bgt imgeo-tabel';

DROP TABLE IF EXISTS imgeo_controle.frequentieverdeling_gml CASCADE;
CREATE TABLE imgeo_controle.frequentieverdeling_gml
(
  tabelnaam character varying, -- Tabelnaam van de objectklasse van het gml-bestand.
  kolomnaam character varying, -- Kolomnaam van de attribuut van de objectklasse.
  kolomwaarde character varying,
  aantal bigint
);
ALTER TABLE imgeo_controle.frequentieverdeling_gml OWNER TO dbuser;
COMMENT ON TABLE imgeo_controle.frequentieverdeling_gml
  IS 'In tabel frequentieverdeling_gml wordt een telling opgeslagen van het aantal attribuutwaarden per objectklasse van de geïmporteerde gmlbestanden.';
COMMENT ON COLUMN imgeo_controle.frequentieverdeling_gml.tabelnaam IS 'Tabelnaam van de objectklasse van het gml-bestand.';
COMMENT ON COLUMN imgeo_controle.frequentieverdeling_gml.kolomnaam IS 'Kolomnaam van de attribuut van de objectklasse. ';

DROP TABLE IF EXISTS imgeo_controle.mapping_gml_db CASCADE;
CREATE TABLE imgeo_controle.mapping_gml_db
(
  gmlbestand character varying, -- gmlbestand
  gmlnaam character varying, -- gml_objectklasse in gmlbestand
  dbnaam character varying, -- db objectklasse in bgt imgeo-tabel.
  extractieview character varying -- db extractieview in bgt imgeo_extractie.
);
ALTER TABLE imgeo_controle.mapping_gml_db OWNER TO dbuser;
COMMENT ON TABLE imgeo_controle.mapping_gml_db
  IS 'mapping_gml-db tabel met daarin de mapping van de gml-bestand, -objectklasse, db-objectklasse en Shape- en DGN-extractieview.';
COMMENT ON COLUMN imgeo_controle.mapping_gml_db.gmlnaam IS 'gml_objectklasse in  gmlbestand';
COMMENT ON COLUMN imgeo_controle.mapping_gml_db.dbnaam IS 'db objectklasse in bgt imgeo-tabel.';
COMMENT ON COLUMN imgeo_controle.mapping_gml_db.extractieview IS 'db extractieview in bgt imgeo_extractie.';


DROP TABLE IF EXISTS imgeo_controle.tel_db CASCADE;
CREATE TABLE imgeo_controle.tel_db
(
  tabelnaam character varying, -- tabelnaam objectklasse van bgt imgeo-tabel
  aantal bigint -- aantal rijen objectklasse van bgt imgeo-tabel
);
ALTER TABLE imgeo_controle.tel_db OWNER TO dbuser;
COMMENT ON TABLE imgeo_controle.tel_db
  IS 'tel_db wordt het aantal rijen van de bgt imgeo-tabel bijgehouden. ';
COMMENT ON COLUMN imgeo_controle.tel_db.tabelnaam IS 'tabelnaam objectklasse van bgt imgeo-tabel';
COMMENT ON COLUMN imgeo_controle.tel_db.aantal IS 'aantal rijen objectklasse van bgt imgeo-tabel';


DROP TABLE IF EXISTS imgeo_controle.tel_gml CASCADE;
CREATE TABLE imgeo_controle.tel_gml
(
  tabelnaam character varying, -- tabelnaam van de gmlobjectklasse
  aantal bigint -- aantal rijen in de gmltabel
);
ALTER TABLE imgeo_controle.tel_gml OWNER TO dbuser;
COMMENT ON TABLE imgeo_controle.tel_gml
  IS 'tel_gml wordt een telling van het aantal rijen van de geïmporteerde gml-tabellen bijgehouden.';
COMMENT ON COLUMN imgeo_controle.tel_gml.tabelnaam IS 'tabelnaam van de gmlobjectklasse';
COMMENT ON COLUMN imgeo_controle.tel_gml.aantal IS 'aantal rijen in de gmltabel';

DROP TABLE IF EXISTS imgeo_controle.vergelijk_gml_db;
CREATE TABLE imgeo_controle.vergelijk_gml_db
(
  tabelnaam character varying,
  aantal_gml bigint, -- aantal rijen van gml tabellen in dbase
  aantal_db bigint, -- aantal rijen van imgeo-tabellen in dbase
  verschil bigint -- verschil gml-tabellen met imgeo-tabellen in dbase
);
ALTER TABLE imgeo_controle.vergelijk_gml_db OWNER TO dbuser;
COMMENT ON TABLE imgeo_controle.vergelijk_gml_db
  IS 'vergelijk_gml_db bevat een vergelijking van de telling in de gmltabellen met de imgeo-tabellen in de dbase';
COMMENT ON COLUMN imgeo_controle.vergelijk_gml_db.aantal_gml IS 'aantal rijen van gml tabellen in dbase';
COMMENT ON COLUMN imgeo_controle.vergelijk_gml_db.aantal_db IS 'aantal rijen van imgeo-tabellen in dbase';
COMMENT ON COLUMN imgeo_controle.vergelijk_gml_db.verschil IS 'verschil gml-tabellen met imgeo-tabellen in dbase';

DROP TABLE IF EXISTS imgeo.bgt_begroeidterreindeel CASCADE;
CREATE TABLE imgeo.bgt_begroeidterreindeel (
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
    bgt_fysiekvoorkomen character varying(200),
    optalud character varying(1),
    plus_fysiekvoorkomen character varying(200),
    geometrie public.geometry(CurvePolygon,28992)
);
