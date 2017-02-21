CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_begroeidterreindeel AS (
SELECT
    identificatie_namespace AS NAMESPACE,
    identificatie_lokaalid  AS LOKAALID,
    objectbegintijd         AS BEGINTIJD,
    objecteindtijd          AS EINDDTIJD,
    tijdstipregistratie     AS TIJDREG,
    eindregistratie         AS EINDREG,
    lv_publicatiedatum      AS LV_PUBDAT,
    bronhouder              AS BRONHOUD,
    inonderzoek             AS INONDERZK,
    relatievehoogteligging  AS HOOGTELIG,
    bgt_status              AS BGTSTATUS,
    plus_status             AS PLUSSTATUS,
    bgt_fysiekvoorkomen     AS BGTFYSVKN,
    'BGT_BTRN_'|| LOWER(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    bgt_fysiekvoorkomen ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
                            AS BESTANDSNAAM,
    optalud                 AS OPTALUD,
    plus_fysiekvoorkomen    AS PLUSFYSVKN,
    geometrie               AS geometrie
FROM imgeo.bgt_begroeidterreindeel);


CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_kruinlijn AS (
SELECT
    identificatie_namespace AS NAMESPACE,
    identificatie_lokaalid  AS LOKAALID,
    objectbegintijd         AS BEGINTIJD,
    objecteindtijd          AS EINDDTIJD,
    tijdstipregistratie     AS TIJDREG,
    eindregistratie         AS EINDREG,
    lv_publicatiedatum      AS LV_PUBDAT,
    bronhouder              AS BRONHOUD,
    inonderzoek             AS INONDERZK,
    relatievehoogteligging  AS HOOGTELIG,
    bgt_status              AS BGTSTATUS,
    plus_status             AS PLUSSTATUS,
    optalud                 AS OPTALUD,
    REPLACE(identificatie_namespace ,'NL.IMGeo','BGT_KLN_')|| LOWER(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    objectklasse_kruinlijn ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
                            AS BESTANDSNAAM,
    objectklasse_kruinlijn  AS HOORTBIJ,
    geometrie               AS GEOMETRIE
FROM imgeo.bgt_kruinlijn);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_nummeraanduidingreeks AS (
SELECT
        bgt_nummeraanduidingreeks.identificatie_namespace AS namespace,
        bgt_nummeraanduidingreeks.identificatie_lokaalid AS lokaalid,
        bgt_nummeraanduidingreeks.objectbegintijd AS begintijd,
        bgt_nummeraanduidingreeks.objecteindtijd AS einddtijd,
        bgt_nummeraanduidingreeks.tijdstipregistratie AS tijdreg,
        bgt_nummeraanduidingreeks.eindregistratie AS eindreg,
        bgt_nummeraanduidingreeks.lv_publicatiedatum AS lv_pubdat,
        bgt_nummeraanduidingreeks.bronhouder AS bronhoud,
        bgt_nummeraanduidingreeks.inonderzoek AS inonderzk,
        bgt_nummeraanduidingreeks.relatievehoogteligging AS hoogtelig,
        bgt_nummeraanduidingreeks.bgt_status AS bgtstatus,
        bgt_nummeraanduidingreeks.plus_status AS plusstatus,
        replace(bgt_nummeraanduidingreeks.identificatie_namespace::text, 'NL.IMGeo'::text, 'BGT_LBL_nummeraanduidingreeks'::text) AS bestandsnaam,
        bgt_nummeraanduidingreeks."identificatieBAGPND" AS bagpndid,
        bgt_nummeraanduidingreeks."identificatieBAGVBOLaagsteHuisnummer" AS bagvbolgst,
        bgt_nummeraanduidingreeks."identificatieBAGVBOHoogsteHuisnummer" AS bagbvohgst,
        bgt_nummeraanduidingreeks.tekst,
        bgt_nummeraanduidingreeks.tekst_afgekort AS tekst_afk,
        bgt_nummeraanduidingreeks.hnr_label_hoek AS hoek,
        bgt_nummeraanduidingreeks.geometrie
FROM imgeo.bgt_nummeraanduidingreeks);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_onbegroeidterreindeel AS (
SELECT
    identificatie_namespace     AS NAMESPACE,
    identificatie_lokaalid      AS LOKAALID,
    objectbegintijd             AS BEGINTIJD,
    objecteindtijd              AS EINDDTIJD,
    tijdstipregistratie         AS TIJDREG,
    eindregistratie             AS EINDREG,
    lv_publicatiedatum          AS LV_PUBDAT,
    bronhouder                  AS BRONHOUD,
    inonderzoek                 AS INONDERZK,
    relatievehoogteligging      AS HOOGTELIG,
    bgt_status                  AS BGTSTATUS,
    plus_status                 AS PLUSSTATUS,
    bgt_fysiekvoorkomen         AS BGTFYSVKN,
    'BGT_OTRN_'|| LOWER(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    bgt_fysiekvoorkomen ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
                                AS BESTANDSNAAM,
    optalud                     AS OPTALUD,
    plus_fysiekvoorkomen        AS PLUSFYSVKN,
    geometrie                   AS GEOMETRIE
FROM imgeo.bgt_onbegroeidterreindeel);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_ondersteunendwaterdeel AS (
SELECT
    identificatie_namespace     AS NAMESPACE,
    identificatie_lokaalid      AS LOKAALID,
    objectbegintijd             AS BEGINTIJD,
    objecteindtijd              AS EINDDTIJD,
    tijdstipregistratie         AS TIJDREG,
    eindregistratie             AS EINDREG,
    lv_publicatiedatum          AS LV_PUBDAT,
    bronhouder                  AS BRONHOUD,
    inonderzoek                 AS INONDERZK,
    relatievehoogteligging      AS HOOGTELIG,
    bgt_status                  AS BGTSTATUS,
    plus_status                 AS PLUSSTATUS,
    bgt_type                    AS BGTTYPE,
    'BGT_OWDL_'|| LOWER(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
                                AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    geometrie                   AS GEOMETRIE
FROM imgeo.bgt_ondersteunendwaterdeel);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_ondersteunendwegdeel AS (
SELECT
    identificatie_namespace     AS NAMESPACE,
    identificatie_lokaalid      AS LOKAALID,
    objectbegintijd             AS BEGINTIJD,
    objecteindtijd              AS EINDDTIJD,
    tijdstipregistratie         AS TIJDREG,
    eindregistratie             AS EINDREG,
    lv_publicatiedatum          AS LV_PUBDAT,
    bronhouder                  AS BRONHOUD,
    inonderzoek                 AS INONDERZK,
    relatievehoogteligging      AS HOOGTELIG,
    bgt_status                  AS BGTSTATUS,
    plus_status                 AS PLUSSTATUS,
    bgt_functie                 AS BGTFUNCTIE,
    case
        when bgt_functie ='niet-bgt'
            then null
        else'BGT_OWGL_'|| LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            bgt_functie ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    bgt_fysiekvoorkomen         AS BGTFYSVKN,
    optalud                     AS OPTALUD,
    plus_functie                AS PLUSFUNCT,
    plus_fysiekvoorkomen        AS PLUSFYSVKN,
    geometrie                   AS GEOMETRIE
FROM imgeo.bgt_ondersteunendwegdeel);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_ongeclassificeerdobject AS (
SELECT
    identificatie_namespace AS NAMESPACE,
    identificatie_lokaalid  AS LOKAALID,
    objectbegintijd         AS BEGINTIJD,
    objecteindtijd          AS EINDDTIJD,
    tijdstipregistratie     AS TIJDREG,
    eindregistratie         AS EINDREG,
    lv_publicatiedatum      AS LV_PUBDAT,
    bronhouder              AS BRONHOUD,
    inonderzoek             AS INONDERZK,
    relatievehoogteligging  AS HOOGTELIG,
    bgt_status              AS BGTSTATUS,
    plus_status             AS PLUSSTATUS,
    CASE
    when identificatie_namespace ='NL.IMGeo'
    then 'BGT_OOT_ongeclassificeerd'
    END                     AS BESTANDSNAAM,
    geometrie               AS geometrie
FROM imgeo.bgt_ongeclassificeerdobject);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_openbareruimtelabel AS (
SELECT
    identificatie_namespace AS NAMESPACE,
    identificatie_lokaalid  AS LOKAALID,
    objectbegintijd         AS BEGINTIJD,
    objecteindtijd          AS EINDDTIJD,
    tijdstipregistratie     AS TIJDREG,
    eindregistratie         AS EINDREG,
    lv_publicatiedatum      AS LV_PUBDAT,
    bronhouder              AS BRONHOUD,
    inonderzoek             AS INONDERZK,
    relatievehoogteligging  AS HOOGTELIG,
    bgt_status              AS BGTSTATUS,
    plus_status             AS PLUSSTATUS,
    identificatiebagopr     AS BAGOPRID,
    openbareruimtetype      AS OPRTYPE,
    REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_LBL_')|| LOWER(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    openbareruimtetype ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
                            AS BESTANDSNAAM,
    opr_label_tekst         AS LABELTEKST,
    opr_label_hoek          AS HOEK,
    geometrie               AS geometrie
FROM imgeo.bgt_openbareruimtelabel);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_overbruggingsdeel AS (
SELECT
    identificatie_namespace     AS NAMESPACE,
    identificatie_lokaalid      AS LOKAALID,
    objectbegintijd             AS BEGINTIJD,
    objecteindtijd              AS EINDDTIJD,
    tijdstipregistratie         AS TIJDREG,
    eindregistratie             AS EINDREG,
    lv_publicatiedatum          AS LV_PUBDAT,
    bronhouder                  AS BRONHOUD,
    inonderzoek                 AS INONDERZK,
    relatievehoogteligging      AS HOOGTELIG,
    bgt_status                  AS BGTSTATUS,
    plus_status                 AS PLUSSTATUS,
    plus_type                   AS PLUSTYPE,
    REPLACE(identificatie_namespace ,'NL.IMGeo','BGT_ODL_overbruggingsdeel')
                                AS BESTANDSNAAM,
    hoortbijtypeoverbrugging    AS HOORTBIJ,
    overbruggingisbeweegbaar    AS ISBEWEEGB,
    geometrie                   AS GEOMETRIE
FROM imgeo.bgt_overbruggingsdeel);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_pand AS (
SELECT
    identificatie_namespace AS NAMESPACE,
    identificatie_lokaalid  AS LOKAALID,
    objectbegintijd         AS BEGINTIJD,
    objecteindtijd          AS EINDDTIJD,
    tijdstipregistratie     AS TIJDREG,
    eindregistratie         AS EINDREG,
    lv_publicatiedatum      AS LV_PUBDAT,
    bronhouder              AS BRONHOUD,
    inonderzoek             AS INONDERZK,
    relatievehoogteligging  AS HOOGTELIG,
    bgt_status              AS BGTSTATUS,
    plus_status             AS PLUSSTATUS,
    REPLACE(identificatie_namespace ,'NL.IMGeo','BGT_PND_pand')
                            AS BESTANDSNAAM,
    identificatiebagpnd     AS BAGPNDID,
    geometrie               AS GEOMETRIE
FROM imgeo.bgt_pand);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_PLAATSBEPALINGSPUNT AS (
SELECT
    identificatie_namespace         AS NAMESPACE,
    identificatie_lokaalid          AS LOKAALID,
    nauwkeurigheid                  AS NAUWKEURIG,
    datum_inwinning                 AS DAT_INWINN,
    inwinnende_instantie            AS INW_INSTAN,
    inwinningsmethode_id            AS INW_METHID,
    REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_PPT')
                                    AS BESTANDSNAAM,
    geometrie                       AS GEOMETRIE
FROM imgeo.BGT_PLAATSBEPALINGSPUNT);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_tunneldeel AS (
SELECT
    identificatie_namespace     AS NAMESPACE,
    identificatie_lokaalid      AS LOKAALID,
    objectbegintijd             AS BEGINTIJD,
    objecteindtijd              AS EINDDTIJD,
    tijdstipregistratie         AS TIJDREG,
    eindregistratie             AS EINDREG,
    lv_publicatiedatum          AS LV_PUBDAT,
    bronhouder                  AS BRONHOUD,
    inonderzoek                 AS INONDERZK,
    relatievehoogteligging      AS HOOGTELIG,
    bgt_status                  AS BGTSTATUS,
    plus_status                 AS PLUSSTATUS,
    REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_TDL_tunneldeel')
                                AS BESTANDSNAAM,
    geometrie                   AS GEOMETRIE
FROM imgeo.bgt_tunneldeel);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_waterdeel AS (
SELECT
    identificatie_namespace     AS NAMESPACE,
    identificatie_lokaalid      AS LOKAALID,
    objectbegintijd             AS BEGINTIJD,
    objecteindtijd              AS EINDDTIJD,
    tijdstipregistratie         AS TIJDREG,
    eindregistratie             AS EINDREG,
    lv_publicatiedatum          AS LV_PUBDAT,
    bronhouder                  AS BRONHOUD,
    inonderzoek                 AS INONDERZK,
    relatievehoogteligging      AS HOOGTELIG,
    bgt_status                  AS BGTSTATUS,
    bgt_type                    AS BGTTYPE,
    plus_type                   AS PLUSTYPE,
    'BGT_WDL_'|| LOWER(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
    bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
                                AS BESTANDSNAAM,
    plus_status                 AS PLUSSTATUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.bgt_waterdeel);

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_wegdeel AS (
SELECT
    bgt_wegdeel.identificatie_namespace AS namespace,
    bgt_wegdeel.identificatie_lokaalid  AS lokaalid,
    bgt_wegdeel.objectbegintijd         AS begintijd,
    bgt_wegdeel.objecteindtijd          AS einddtijd,
    bgt_wegdeel.tijdstipregistratie     AS tijdreg,
    bgt_wegdeel.eindregistratie         AS eindreg,
    bgt_wegdeel.lv_publicatiedatum      AS lv_pubdat,
    bgt_wegdeel.bronhouder              AS bronhoud,
    bgt_wegdeel.inonderzoek             AS inonderzk,
    bgt_wegdeel.relatievehoogteligging  AS hoogtelig,
    bgt_wegdeel.bgt_status              AS bgtstatus,
    bgt_wegdeel.plus_status             AS plusstatus,
    bgt_wegdeel.bgt_functie             AS bgtfunctie,
    case
        when bgt_functie ='niet-bgt'
            then null
        else 'BGT_WGL_'|| LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            bgt_functie ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                                 AS BESTANDSNAAM,
    bgt_wegdeel.bgt_fysiekvoorkomen     AS bgtfysvkn,
    bgt_wegdeel.optalud                 AS optalud,
    bgt_wegdeel.plus_functie            AS plusfunct,
    bgt_wegdeel.plus_fysiekvoorkomen    AS plusfysvkn,
    bgt_wegdeel.geometrie               AS geometrie
FROM imgeo.bgt_wegdeel);
