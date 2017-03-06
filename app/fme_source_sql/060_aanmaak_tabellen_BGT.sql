-- Table: imgeo."BAG_Ligplaats"
DROP TABLE IF EXISTS imgeo."BAG_Ligplaats" CASCADE;
CREATE TABLE imgeo."BAG_Ligplaats"
(
  "BAGID" character varying(18),
  bestandsnaam character varying(15),
  geometrie geometry(Geometry, 28992)
);
ALTER TABLE imgeo."BAG_Ligplaats" OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo."BAG_Ligplaats_geometrie_1487779941374";
CREATE INDEX "BAG_Ligplaats_geometrie_1487779941374"  ON imgeo."BAG_Ligplaats"  USING gist  (geometrie);

-- Table: imgeo."BAG_Standplaats"
DROP TABLE IF EXISTS imgeo."BAG_Standplaats" CASCADE;
CREATE TABLE imgeo."BAG_Standplaats"
(
  "BAGID" character varying(18),
  bestandsnaam character varying(15),
  geometrie geometry(Geometry,28992)
);
ALTER TABLE imgeo."BAG_Standplaats" OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo."BAG_Standplaats_geometrie_148777994161";
CREATE INDEX "BAG_Standplaats_geometrie_148777994161"  ON imgeo."BAG_Standplaats" USING gist  (geometrie);

-- Table: imgeo."CFT_Onderbouw"
DROP TABLE IF EXISTS imgeo."CFT_Onderbouw" CASCADE;
CREATE TABLE imgeo."CFT_Onderbouw"
(
  eindregistratie date,
  relatievehoogteligging smallint,
  bestandsnaam character varying(15),
  geometrie geometry(Geometry,28992)
);
ALTER TABLE imgeo."CFT_Onderbouw" OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo."CFT_Onderbouw_geometrie_1487603335675";
CREATE INDEX "CFT_Onderbouw_geometrie_1487603335675"  ON imgeo."CFT_Onderbouw" USING gist (geometrie);

-- Table: imgeo."CFT_Overbouw"
DROP TABLE IF EXISTS imgeo."CFT_Overbouw" CASCADE;
CREATE TABLE imgeo."CFT_Overbouw"
(
  eindregistratie date,
  relatievehoogteligging smallint,
  bestandsnaam character varying(12),
  geometrie geometry(Geometry,28992)
);
ALTER TABLE imgeo."CFT_Overbouw"  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo."CFT_Overbouw_geometrie_14876030788";
CREATE INDEX "CFT_Overbouw_geometrie_14876030788"  ON imgeo."CFT_Overbouw"  USING gist  (geometrie);

-- Table: imgeo.bgt_begroeidterreindeel
DROP TABLE IF EXISTS imgeo.bgt_begroeidterreindeel CASCADE;
CREATE TABLE imgeo.bgt_begroeidterreindeel
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
  bgt_fysiekvoorkomen character varying(200),
  optalud character varying(1),
  plus_fysiekvoorkomen character varying(200),
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_begroeidterreindeel
  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_begroeidterreindeel_geometrie_1474551421494;
CREATE INDEX bgt_begroeidterreindeel_geometrie_1474551421494  ON imgeo.bgt_begroeidterreindeel  USING gist  (geometrie);

-- Table: imgeo.bgt_kruinlijn
DROP TABLE IF EXISTS imgeo.bgt_kruinlijn;
CREATE TABLE imgeo.bgt_kruinlijn
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
  optalud character varying(1),
  objectklasse_kruinlijn character varying(200),
  geometrie geometry(CompoundCurve,28992)
);
ALTER TABLE imgeo.bgt_kruinlijn  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_kruinlijn_geometrie_1474551421465;
CREATE INDEX bgt_kruinlijn_geometrie_1474551421465  ON imgeo.bgt_kruinlijn  USING gist  (geometrie);

-- Table: imgeo.bgt_nummeraanduidingreeks
DROP TABLE IF EXISTS imgeo.bgt_nummeraanduidingreeks CASCADE;
CREATE TABLE imgeo.bgt_nummeraanduidingreeks
(
  objectbegintijd date,
  objecteindtijd date,
  eindregistratie date,
  bronhouder character varying(40),
  tijdstipregistratie date,
  inonderzoek character varying(1),
  relatievehoogteligging smallint,
  lv_publicatiedatum date,
  bgt_status character varying(8),
  plus_status character varying(8),
  identificatie_namespace character varying(8),
  tekst character varying(200),
  tekst_afgekort character varying(200),
  hnr_label_hoek real,
  identificatie_lokaalid character varying(38),
  "identificatieBAGVBOLaagsteHuisnummer" character varying(20),
  "identificatieBAGVBOHoogsteHuisnummer" character varying(20),
  "identificatieBAGPND" character varying(20),
  geometrie geometry(Geometry,28992)
);
ALTER TABLE imgeo.bgt_nummeraanduidingreeks
  OWNER TO postgres;
DROP INDEX IF EXISTS imgeo.bgt_nummeraanduidingreeks_geometrie_1488299979304;
CREATE INDEX bgt_nummeraanduidingreeks_geometrie_1488299979304  ON imgeo.bgt_nummeraanduidingreeks  USING gist  (geometrie);

-- Table: imgeo.bgt_onbegroeidterreindeel

DROP TABLE IF EXISTS imgeo.bgt_onbegroeidterreindeel CASCADE;

CREATE TABLE imgeo.bgt_onbegroeidterreindeel
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
  bgt_fysiekvoorkomen character varying(200),
  optalud character varying(1),
  plus_fysiekvoorkomen character varying(200),
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_onbegroeidterreindeel  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_onbegroeidterreindeel_geometrie_1474551429771;
CREATE INDEX bgt_onbegroeidterreindeel_geometrie_1474551429771  ON imgeo.bgt_onbegroeidterreindeel  USING gist  (geometrie);

-- Table: imgeo.bgt_ondersteunendwaterdeel
DROP TABLE IF EXISTS imgeo.bgt_ondersteunendwaterdeel CASCADE;

CREATE TABLE imgeo.bgt_ondersteunendwaterdeel
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
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_ondersteunendwaterdeel  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_ondersteunendwaterdeel_geometrie_1474551427579;
CREATE INDEX bgt_ondersteunendwaterdeel_geometrie_1474551427579  ON imgeo.bgt_ondersteunendwaterdeel  USING gist  (geometrie);

-- Table: imgeo.bgt_ondersteunendwegdeel
DROP TABLE IF EXISTS imgeo.bgt_ondersteunendwegdeel CASCADE;

CREATE TABLE imgeo.bgt_ondersteunendwegdeel
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
  bgt_functie character varying(200),
  bgt_fysiekvoorkomen character varying(200),
  optalud character varying(1),
  plus_functie character varying(200),
  plus_fysiekvoorkomen character varying(200),
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_ondersteunendwegdeel  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_ondersteunendwegdeel_geometrie_1474551437656;
CREATE INDEX bgt_ondersteunendwegdeel_geometrie_1474551437656  ON imgeo.bgt_ondersteunendwegdeel  USING gist  (geometrie);

-- Table: imgeo.bgt_ongeclassificeerdobject
DROP TABLE IF EXISTS imgeo.bgt_ongeclassificeerdobject CASCADE;

CREATE TABLE imgeo.bgt_ongeclassificeerdobject
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
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_ongeclassificeerdobject  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_ongeclassificeerdobject_geometrie_1474551426167;
CREATE INDEX bgt_ongeclassificeerdobject_geometrie_1474551426167  ON imgeo.bgt_ongeclassificeerdobject  USING gist  (geometrie);

-- Table: imgeo.bgt_openbareruimtelabel

DROP TABLE IF EXISTS imgeo.bgt_openbareruimtelabel CASCADE;
CREATE TABLE imgeo.bgt_openbareruimtelabel
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
  identificatiebagopr character varying(20),
  openbareruimtetype character varying(200),
  opr_label_tekst character varying(200),
  opr_label_hoek real,
  geometrie geometry(Point,28992)
);
ALTER TABLE imgeo.bgt_openbareruimtelabel  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_openbareruimtelabel_geometrie_1474551417685;
CREATE INDEX bgt_openbareruimtelabel_geometrie_1474551417685  ON imgeo.bgt_openbareruimtelabel  USING gist  (geometrie);

-- Table: imgeo.bgt_overbruggingsdeel
DROP TABLE IF EXISTS imgeo.bgt_overbruggingsdeel CASCADE;

CREATE TABLE imgeo.bgt_overbruggingsdeel
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
  plus_type character varying(200),
  hoortbijtypeoverbrugging character varying(200),
  overbruggingisbeweegbaar character varying(1),
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_overbruggingsdeel
  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_overbruggingsdeel_geometrie_147455141867;
CREATE INDEX bgt_overbruggingsdeel_geometrie_147455141867  ON imgeo.bgt_overbruggingsdeel  USING gist  (geometrie);

-- Table: imgeo.bgt_pand
DROP TABLE IF EXISTS imgeo.bgt_pand CASCADE;

CREATE TABLE imgeo.bgt_pand
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
  identificatiebagpnd character varying(20),
  geometrie geometry(Geometry,28992)
);
ALTER TABLE imgeo.bgt_pand  OWNER TO postgres;
DROP INDEX IF EXISTS imgeo.bgt_pand_geometrie_1488195514270;
CREATE INDEX bgt_pand_geometrie_1488195514270  ON imgeo.bgt_pand  USING gist  (geometrie);

-- Table: imgeo.bgt_tunneldeel
DROP TABLE IF EXISTS imgeo.bgt_tunneldeel CASCADE;

CREATE TABLE imgeo.bgt_tunneldeel
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
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_tunneldeel
  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_tunneldeel_geometrie_1474551427963;
CREATE INDEX bgt_tunneldeel_geometrie_1474551427963  ON imgeo.bgt_tunneldeel  USING gist  (geometrie);

-- Table: imgeo.bgt_waterdeel
DROP TABLE IF EXISTS imgeo.bgt_waterdeel CASCADE;

CREATE TABLE imgeo.bgt_waterdeel
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
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_waterdeel  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_waterdeel_geometrie_1474551438760;
CREATE INDEX bgt_waterdeel_geometrie_1474551438760  ON imgeo.bgt_waterdeel  USING gist  (geometrie);

-- Table: imgeo.bgt_wegdeel
DROP TABLE IF EXISTS imgeo.bgt_wegdeel CASCADE;

CREATE TABLE imgeo.bgt_wegdeel
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
  bgt_functie character varying(200),
  bgt_fysiekvoorkomen character varying(200),
  optalud character varying(1),
  plus_functie character varying(200),
  plus_fysiekvoorkomen character varying(200),
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.bgt_wegdeel  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.bgt_wegdeel_geometrie_1474551433914;
CREATE INDEX bgt_wegdeel_geometrie_1474551433914  ON imgeo.bgt_wegdeel  USING gist  (geometrie);

-- Table: imgeo.imgeo_bak
DROP TABLE IF EXISTS imgeo.imgeo_bak CASCADE;

CREATE TABLE imgeo.imgeo_bak
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
ALTER TABLE imgeo.imgeo_bak  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_bak_geometrie_1474551417568;
CREATE INDEX imgeo_bak_geometrie_1474551417568  ON imgeo.imgeo_bak  USING gist  (geometrie);

-- Table: imgeo.imgeo_bord
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

-- Table: imgeo.imgeo_functioneelgebied
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

-- Table: imgeo.imgeo_gebouwinstallatie
DROP TABLE IF EXISTS imgeo.imgeo_gebouwinstallatie CASCADE;

CREATE TABLE imgeo.imgeo_gebouwinstallatie
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
  geometrie geometry(CurvePolygon,28992)
);
ALTER TABLE imgeo.imgeo_gebouwinstallatie  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_gebouwinstallatie_geometrie_1474551418282;
CREATE INDEX imgeo_gebouwinstallatie_geometrie_1474551418282  ON imgeo.imgeo_gebouwinstallatie  USING gist  (geometrie);

-- Table: imgeo.imgeo_installatie
DROP TABLE IF EXISTS imgeo.imgeo_installatie CASCADE;

CREATE TABLE imgeo.imgeo_installatie
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
ALTER TABLE imgeo.imgeo_installatie  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_installatie_geometrie_1474551439125;
CREATE INDEX imgeo_installatie_geometrie_1474551439125  ON imgeo.imgeo_installatie  USING gist  (geometrie);

-- Table: imgeo.imgeo_kast
DROP TABLE IF EXISTS imgeo.imgeo_kast CASCADE;

CREATE TABLE imgeo.imgeo_kast
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
ALTER TABLE imgeo.imgeo_kast  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_kast_geometrie_1474551421374;
CREATE INDEX imgeo_kast_geometrie_1474551421374  ON imgeo.imgeo_kast  USING gist  (geometrie);

-- Table: imgeo.imgeo_kunstwerkdeel
DROP TABLE IF EXISTS imgeo.imgeo_kunstwerkdeel CASCADE;

CREATE TABLE imgeo.imgeo_kunstwerkdeel
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
ALTER TABLE imgeo.imgeo_kunstwerkdeel  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_kunstwerkdeel_geometrie_1474551427480;
CREATE INDEX imgeo_kunstwerkdeel_geometrie_1474551427480  ON imgeo.imgeo_kunstwerkdeel  USING gist  (geometrie);

-- Table: imgeo.imgeo_mast
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

-- Table: imgeo.imgeo_overigbouwwerk
DROP TABLE IF EXISTS imgeo.imgeo_overigbouwwerk CASCADE;

CREATE TABLE imgeo.imgeo_overigbouwwerk
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
  geometrie geometry(MultiSurface,28992)
);
ALTER TABLE imgeo.imgeo_overigbouwwerk  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_overigbouwwerk_geometrie_147455142617;
CREATE INDEX imgeo_overigbouwwerk_geometrie_147455142617  ON imgeo.imgeo_overigbouwwerk  USING gist  (geometrie);

-- Table: imgeo.imgeo_overigescheiding
DROP TABLE IF EXISTS imgeo.imgeo_overigescheiding CASCADE;

CREATE TABLE imgeo.imgeo_overigescheiding
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
ALTER TABLE imgeo.imgeo_overigescheiding  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_overigescheiding_geometrie_1474551438643;
CREATE INDEX imgeo_overigescheiding_geometrie_1474551438643  ON imgeo.imgeo_overigescheiding  USING gist  (geometrie);

-- Table: imgeo.imgeo_paal
DROP TABLE IF EXISTS imgeo.imgeo_paal CASCADE;

CREATE TABLE imgeo.imgeo_paal
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
  hectometeraanduiding character varying(200),
  plus_type character varying(200),
  geometrie geometry(Point,28992)
);
ALTER TABLE imgeo.imgeo_paal  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_paal_geometrie_1474551432557;
CREATE INDEX imgeo_paal_geometrie_1474551432557  ON imgeo.imgeo_paal  USING gist  (geometrie);

-- Table: imgeo.imgeo_put
DROP TABLE IF EXISTS imgeo.imgeo_put CASCADE;

CREATE TABLE imgeo.imgeo_put
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
ALTER TABLE imgeo.imgeo_put
  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_put_geometrie_1474551437533;
CREATE INDEX imgeo_put_geometrie_1474551437533  ON imgeo.imgeo_put  USING gist  (geometrie);

-- Table: imgeo.imgeo_scheiding
DROP TABLE IF EXISTS imgeo.imgeo_scheiding CASCADE;
CREATE TABLE imgeo.imgeo_scheiding
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
ALTER TABLE imgeo.imgeo_scheiding  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_scheiding_geometrie_1474551426190;
CREATE INDEX imgeo_scheiding_geometrie_1474551426190  ON imgeo.imgeo_scheiding  USING gist  (geometrie);

-- Table: imgeo.imgeo_sensor

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

-- Table: imgeo.imgeo_spoor
DROP TABLE IF EXISTS imgeo.imgeo_spoor CASCADE;

CREATE TABLE imgeo.imgeo_spoor
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
  bgt_functie character varying(200),
  plus_functie character varying(200),
  geometrie geometry(CompoundCurve,28992)
);
ALTER TABLE imgeo.imgeo_spoor  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_spoor_geometrie_1474551438674;
CREATE INDEX imgeo_spoor_geometrie_1474551438674  ON imgeo.imgeo_spoor  USING gist  (geometrie);

-- Table: imgeo.imgeo_straatmeubilair
DROP TABLE IF EXISTS imgeo.imgeo_straatmeubilair CASCADE;

CREATE TABLE imgeo.imgeo_straatmeubilair
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
  plus_type character varying(200),
  bgt_type character varying(200),
  geometrie geometry(Point,28992)
);
ALTER TABLE imgeo.imgeo_straatmeubilair  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_straatmeubilair_geometrie_1474551432511;
CREATE INDEX imgeo_straatmeubilair_geometrie_1474551432511  ON imgeo.imgeo_straatmeubilair  USING gist  (geometrie);

-- Table: imgeo.imgeo_vegetatieobject
DROP TABLE IF EXISTS imgeo.imgeo_vegetatieobject CASCADE;

CREATE TABLE imgeo.imgeo_vegetatieobject
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
  plus_type character varying(200),
  bgt_type character varying(200),
  geometrie geometry(Geometry,28992)
);
ALTER TABLE imgeo.imgeo_vegetatieobject  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_vegetatieobject_geometrie_14745514289;
CREATE INDEX imgeo_vegetatieobject_geometrie_14745514289  ON imgeo.imgeo_vegetatieobject  USING gist  (geometrie);

-- Table: imgeo.imgeo_waterinrichtingselement
DROP TABLE IF EXISTS imgeo.imgeo_waterinrichtingselement CASCADE;

CREATE TABLE imgeo.imgeo_waterinrichtingselement
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
ALTER TABLE imgeo.imgeo_waterinrichtingselement  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_waterinrichtingselement_geometrie_1474551427938;
CREATE INDEX imgeo_waterinrichtingselement_geometrie_1474551427938  ON imgeo.imgeo_waterinrichtingselement  USING gist  (geometrie);

-- Table: imgeo.imgeo_weginrichtingselement
DROP TABLE IF EXISTS imgeo.imgeo_weginrichtingselement CASCADE;

CREATE TABLE imgeo.imgeo_weginrichtingselement
(
  identificatie_namespace character varying(8),
  identificatie_lokaalid character varying(38),
  objectbegintijd date,
  objecteindtijd date,
  eindregistratie timestamp without time zone,
  tijdstipregistratie timestamp without time zone,
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
ALTER TABLE imgeo.imgeo_weginrichtingselement  OWNER TO dbuser;
DROP INDEX IF EXISTS imgeo.imgeo_weginrichtingselement_geometrie_1474551427986;
CREATE INDEX imgeo_weginrichtingselement_geometrie_1474551427986  ON imgeo.imgeo_weginrichtingselement  USING gist  (geometrie);

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
