--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.5

-- Started on 2016-11-28 10:08:21 CET

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 11 (class 2615 OID 1264795)
-- Name: imgeo; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA imgeo;

SET search_path = imgeo, pg_catalog, public;

SET default_with_oids = false;

--
-- TOC entry 323 (class 1259 OID 6178152)
-- Name: bgt_begroeidterreindeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_begroeidterreindeel (
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


--
-- TOC entry 324 (class 1259 OID 6178213)
-- Name: bgt_kruinlijn; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_kruinlijn (
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
    geometrie public.geometry(CompoundCurve,28992)
);


--
-- TOC entry 340 (class 1259 OID 6188560)
-- Name: bgt_nummeraanduidingreeks; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_nummeraanduidingreeks (
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
    id_bagvbolaagste_huisnummer character varying(20),
    id_bagvbohoogste_huisnummer character varying(20),
    label_tekst character varying(200),
    hoek real,
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 330 (class 1259 OID 6182568)
-- Name: bgt_onbegroeidterreindeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_onbegroeidterreindeel (
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


--
-- TOC entry 331 (class 1259 OID 6185467)
-- Name: bgt_ondersteunendwaterdeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_ondersteunendwaterdeel (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 332 (class 1259 OID 6187379)
-- Name: bgt_ondersteunendwegdeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_ondersteunendwegdeel (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 333 (class 1259 OID 6188407)
-- Name: bgt_ongeclassificeerdobject; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_ongeclassificeerdobject (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 334 (class 1259 OID 6188417)
-- Name: bgt_openbareruimtelabel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_openbareruimtelabel (
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
    label_tekst character varying(200),
    hoek real,
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 335 (class 1259 OID 6188471)
-- Name: bgt_overbruggingsdeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_overbruggingsdeel (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 339 (class 1259 OID 6188554)
-- Name: bgt_pand; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_pand (
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
    geometrie public.geometry(MultiSurface,28992)
);


--
-- TOC entry 345 (class 1259 OID 6189387)
-- Name: bgt_tunneldeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_tunneldeel (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 347 (class 1259 OID 6189433)
-- Name: bgt_waterdeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_waterdeel (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 349 (class 1259 OID 6191927)
-- Name: bgt_wegdeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE bgt_wegdeel (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 322 (class 1259 OID 6178143)
-- Name: imgeo_bak; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_bak (
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
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 382 (class 1259 OID 6198645)
-- Name: imgeo_bord; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_bord (
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
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 325 (class 1259 OID 6182480)
-- Name: imgeo_functioneelgebied; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_functioneelgebied (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 326 (class 1259 OID 6182490)
-- Name: imgeo_gebouwinstallatie; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_gebouwinstallatie (
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
    geometrie public.geometry(CurvePolygon,28992)
);


--
-- TOC entry 327 (class 1259 OID 6182520)
-- Name: imgeo_installatie; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_installatie (
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
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 328 (class 1259 OID 6182530)
-- Name: imgeo_kast; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_kast (
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
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 329 (class 1259 OID 6182536)
-- Name: imgeo_kunstwerkdeel; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_kunstwerkdeel (
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
    geometrie public.geometry(Geometry,28992)
);


--
-- TOC entry 383 (class 1259 OID 6198652)
-- Name: imgeo_mast; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_mast (
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
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 336 (class 1259 OID 6188510)
-- Name: imgeo_overigbouwwerk; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_overigbouwwerk (
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
    geometrie public.geometry(MultiSurface,28992)
);


--
-- TOC entry 337 (class 1259 OID 6188516)
-- Name: imgeo_overigescheiding; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_overigescheiding (
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
    geometrie public.geometry(Geometry,28992)
);


--
-- TOC entry 338 (class 1259 OID 6188530)
-- Name: imgeo_paal; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_paal (
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
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 341 (class 1259 OID 6189210)
-- Name: imgeo_put; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_put (
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
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 342 (class 1259 OID 6189218)
-- Name: imgeo_scheiding; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_scheiding (
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
    geometrie public.geometry(Geometry,28992)
);


--
-- TOC entry 384 (class 1259 OID 6198659)
-- Name: imgeo_sensor; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_sensor (
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
    geometrie public.geometry(Geometry,28992)
);


--
-- TOC entry 343 (class 1259 OID 6189365)
-- Name: imgeo_spoor; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_spoor (
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
    geometrie public.geometry(CompoundCurve,28992)
);


--
-- TOC entry 344 (class 1259 OID 6189376)
-- Name: imgeo_straatmeubilair; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_straatmeubilair (
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
    geometrie public.geometry(Point,28992)
);


--
-- TOC entry 346 (class 1259 OID 6189397)
-- Name: imgeo_vegetatieobject; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_vegetatieobject (
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
    geometrie public.geometry(Geometry,28992)
);


--
-- TOC entry 348 (class 1259 OID 6191799)
-- Name: imgeo_waterinrichtingselement; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_waterinrichtingselement (
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
    geometrie public.geometry(Geometry,28992)
);


--
-- TOC entry 350 (class 1259 OID 6198359)
-- Name: imgeo_weginrichtingselement; Type: TABLE; Schema: imgeo; Owner: -
--

CREATE TABLE imgeo_weginrichtingselement (
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
    geometrie public.geometry(Geometry,28992)
);


--
-- TOC entry 4177 (class 1259 OID 6198405)
-- Name: bgt_begroeidterreindeel_geometrie_1474551421494; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_begroeidterreindeel_geometrie_1474551421494 ON bgt_begroeidterreindeel USING gist (geometrie);


--
-- TOC entry 4178 (class 1259 OID 6198403)
-- Name: bgt_kruinlijn_geometrie_1474551421465; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_kruinlijn_geometrie_1474551421465 ON bgt_kruinlijn USING gist (geometrie);


--
-- TOC entry 4195 (class 1259 OID 6198395)
-- Name: bgt_nummeraanduidingreeks_geometrie_147455141947; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_nummeraanduidingreeks_geometrie_147455141947 ON bgt_nummeraanduidingreeks USING gist (geometrie);


--
-- TOC entry 4185 (class 1259 OID 6198443)
-- Name: bgt_onbegroeidterreindeel_geometrie_1474551429771; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_onbegroeidterreindeel_geometrie_1474551429771 ON bgt_onbegroeidterreindeel USING gist (geometrie);


--
-- TOC entry 4186 (class 1259 OID 6198427)
-- Name: bgt_ondersteunendwaterdeel_geometrie_1474551427579; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_ondersteunendwaterdeel_geometrie_1474551427579 ON bgt_ondersteunendwaterdeel USING gist (geometrie);


--
-- TOC entry 4187 (class 1259 OID 6198462)
-- Name: bgt_ondersteunendwegdeel_geometrie_1474551437656; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_ondersteunendwegdeel_geometrie_1474551437656 ON bgt_ondersteunendwegdeel USING gist (geometrie);


--
-- TOC entry 4188 (class 1259 OID 6198418)
-- Name: bgt_ongeclassificeerdobject_geometrie_1474551426167; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_ongeclassificeerdobject_geometrie_1474551426167 ON bgt_ongeclassificeerdobject USING gist (geometrie);


--
-- TOC entry 4189 (class 1259 OID 6198381)
-- Name: bgt_openbareruimtelabel_geometrie_1474551417685; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_openbareruimtelabel_geometrie_1474551417685 ON bgt_openbareruimtelabel USING gist (geometrie);


--
-- TOC entry 4190 (class 1259 OID 6198387)
-- Name: bgt_overbruggingsdeel_geometrie_147455141867; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_overbruggingsdeel_geometrie_147455141867 ON bgt_overbruggingsdeel USING gist (geometrie);


--
-- TOC entry 4194 (class 1259 OID 6198410)
-- Name: bgt_pand_geometrie_1474551422707; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_pand_geometrie_1474551422707 ON bgt_pand USING gist (geometrie);


--
-- TOC entry 4200 (class 1259 OID 6198435)
-- Name: bgt_tunneldeel_geometrie_1474551427963; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_tunneldeel_geometrie_1474551427963 ON bgt_tunneldeel USING gist (geometrie);


--
-- TOC entry 4202 (class 1259 OID 6198472)
-- Name: bgt_waterdeel_geometrie_1474551438760; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_waterdeel_geometrie_1474551438760 ON bgt_waterdeel USING gist (geometrie);


--
-- TOC entry 4204 (class 1259 OID 6198454)
-- Name: bgt_wegdeel_geometrie_1474551433914; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX bgt_wegdeel_geometrie_1474551433914 ON bgt_wegdeel USING gist (geometrie);


--
-- TOC entry 4176 (class 1259 OID 6198378)
-- Name: imgeo_bak_geometrie_1474551417568; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_bak_geometrie_1474551417568 ON imgeo_bak USING gist (geometrie);


--
-- TOC entry 4207 (class 1259 OID 6198651)
-- Name: imgeo_bord_geometrie_1465822102262; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_bord_geometrie_1465822102262 ON imgeo_bord USING gist (geometrie);


--
-- TOC entry 4179 (class 1259 OID 6198637)
-- Name: imgeo_functioneelgebied_geometrie_1465822099300; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_functioneelgebied_geometrie_1465822099300 ON imgeo_functioneelgebied USING gist (geometrie);


--
-- TOC entry 4180 (class 1259 OID 6198432)
-- Name: imgeo_functioneelgebied_geometrie_1474551427915; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_functioneelgebied_geometrie_1474551427915 ON imgeo_functioneelgebied USING gist (geometrie);


--
-- TOC entry 4181 (class 1259 OID 6198391)
-- Name: imgeo_gebouwinstallatie_geometrie_1474551418282; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_gebouwinstallatie_geometrie_1474551418282 ON imgeo_gebouwinstallatie USING gist (geometrie);


--
-- TOC entry 4182 (class 1259 OID 6198477)
-- Name: imgeo_installatie_geometrie_1474551439125; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_installatie_geometrie_1474551439125 ON imgeo_installatie USING gist (geometrie);


--
-- TOC entry 4183 (class 1259 OID 6198400)
-- Name: imgeo_kast_geometrie_1474551421374; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_kast_geometrie_1474551421374 ON imgeo_kast USING gist (geometrie);


--
-- TOC entry 4184 (class 1259 OID 6198423)
-- Name: imgeo_kunstwerkdeel_geometrie_1474551427480; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_kunstwerkdeel_geometrie_1474551427480 ON imgeo_kunstwerkdeel USING gist (geometrie);


--
-- TOC entry 4208 (class 1259 OID 6198658)
-- Name: imgeo_mast_geometrie_1465822102262; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_mast_geometrie_1465822102262 ON imgeo_mast USING gist (geometrie);


--
-- TOC entry 4191 (class 1259 OID 6198414)
-- Name: imgeo_overigbouwwerk_geometrie_147455142617; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_overigbouwwerk_geometrie_147455142617 ON imgeo_overigbouwwerk USING gist (geometrie);


--
-- TOC entry 4192 (class 1259 OID 6198467)
-- Name: imgeo_overigescheiding_geometrie_1474551438643; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_overigescheiding_geometrie_1474551438643 ON imgeo_overigescheiding USING gist (geometrie);


--
-- TOC entry 4193 (class 1259 OID 6198450)
-- Name: imgeo_paal_geometrie_1474551432557; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_paal_geometrie_1474551432557 ON imgeo_paal USING gist (geometrie);


--
-- TOC entry 4196 (class 1259 OID 6198459)
-- Name: imgeo_put_geometrie_1474551437533; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_put_geometrie_1474551437533 ON imgeo_put USING gist (geometrie);


--
-- TOC entry 4197 (class 1259 OID 6198419)
-- Name: imgeo_scheiding_geometrie_1474551426190; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_scheiding_geometrie_1474551426190 ON imgeo_scheiding USING gist (geometrie);


--
-- TOC entry 4198 (class 1259 OID 6198469)
-- Name: imgeo_spoor_geometrie_1474551438674; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_spoor_geometrie_1474551438674 ON imgeo_spoor USING gist (geometrie);


--
-- TOC entry 4199 (class 1259 OID 6198448)
-- Name: imgeo_straatmeubilair_geometrie_1474551432511; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_straatmeubilair_geometrie_1474551432511 ON imgeo_straatmeubilair USING gist (geometrie);


--
-- TOC entry 4201 (class 1259 OID 6198439)
-- Name: imgeo_vegetatieobject_geometrie_14745514289; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_vegetatieobject_geometrie_14745514289 ON imgeo_vegetatieobject USING gist (geometrie);


--
-- TOC entry 4203 (class 1259 OID 6198433)
-- Name: imgeo_waterinrichtingselement_geometrie_1474551427938; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_waterinrichtingselement_geometrie_1474551427938 ON imgeo_waterinrichtingselement USING gist (geometrie);


--
-- TOC entry 4205 (class 1259 OID 6198437)
-- Name: imgeo_weginrichtingselement_geometrie_1474551427986; Type: INDEX; Schema: imgeo; Owner: -
--

CREATE INDEX imgeo_weginrichtingselement_geometrie_1474551427986 ON imgeo_weginrichtingselement USING gist (geometrie);


-- Completed on 2016-11-28 10:08:25 CET

--
-- PostgreSQL database dump complete
--

