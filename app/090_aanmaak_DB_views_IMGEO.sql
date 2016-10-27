CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_BAK AS (
SELECT imgeo_bak.identificatie_namespace AS namespace,
    imgeo_bak.identificatie_lokaalid  AS lokaalid,
    imgeo_bak.objectbegintijd         AS begintijd,
    imgeo_bak.objecteindtijd          AS einddtijd,
    imgeo_bak.tijdstipregistratie     AS tijdreg,
    imgeo_bak.eindregistratie         AS eindreg,
    imgeo_bak.lv_publicatiedatum      AS lv_pubdat,
    imgeo_bak.bronhouder              AS bronhoud,
    imgeo_bak.inonderzoek             AS inonderzk,
    imgeo_bak.relatievehoogteligging  AS hoogtelig,
    imgeo_bak.bgt_status              AS bgtstatus,
    imgeo_bak.plus_status             AS plusstatus,
    imgeo_bak.bgt_type                AS bgttype,
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_BAK_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                               AS BESTANDSNAAM,
    plus_type                         AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_BAK_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_BAK_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                                 AS BESTANDSNAAM_PLUS,
    imgeo_bak.geometrie                 AS GEOMETRIE
FROM imgeo.imgeo_bak);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_BORD AS (
SELECT identificatie_namespace     AS NAMESPACE,
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
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_BRD_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                     AS BESTANDSNAAM,
    plus_type               AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_BRD_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_BRD_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end
    AS BESTANDSNAAM_PLUS,
    geometrie                AS GEOMETRIE
FROM imgeo.IMGEO_BORD);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_functioneelgebied AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_FGD_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_FGD_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_FGD_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    naam                        AS NAAM,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_functioneelgebied);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_gebouwinstallatie AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_GISE_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_GISE_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_GISE_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_gebouwinstallatie);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_installatie AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_ISE_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_ISE_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_ISE_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_installatie);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_kast AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_KST_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_KST_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_KST_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))end
        end                     AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_kast);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_kunstwerkdeel AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else
        'BGT_KDL_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_KDL_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_KDL_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                        AS BESTANDSNAAM_PLUS,
    geometrie                  AS GEOMETRIE
FROM imgeo.imgeo_kunstwerkdeel);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_MAST AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else
        'BGT_MST_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_MST_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_MST_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.IMGEO_MAST);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_overigbouwwerk AS (
SELECT
    imgeo_overigbouwwerk.identificatie_namespace    AS namespace,
    imgeo_overigbouwwerk.identificatie_lokaalid     AS lokaalid,
    imgeo_overigbouwwerk.objectbegintijd            AS begintijd,
    imgeo_overigbouwwerk.objecteindtijd             AS einddtijd,
    imgeo_overigbouwwerk.tijdstipregistratie        AS tijdreg,
    imgeo_overigbouwwerk.eindregistratie            AS eindreg,
    imgeo_overigbouwwerk.lv_publicatiedatum         AS lv_pubdat,
    imgeo_overigbouwwerk.bronhouder                 AS bronhoud,
    imgeo_overigbouwwerk.inonderzoek                AS inonderzk,
    imgeo_overigbouwwerk.relatievehoogteligging     AS hoogtelig,
    imgeo_overigbouwwerk.bgt_status                 AS bgtstatus,
    imgeo_overigbouwwerk.plus_status                AS plusstatus,
    imgeo_overigbouwwerk.bgt_type                   AS bgttype,
    case
        when bgt_type ='niet-bgt'
        then null
    else
        'BGT_OBW_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                                             AS BESTANDSNAAM,
    imgeo_overigbouwwerk.plus_type                  AS plustype,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_OBW_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_OBW_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                                             AS BESTANDSNAAM_PLUS,
    imgeo_overigbouwwerk.geometrie
FROM imgeo.imgeo_overigbouwwerk);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_overigescheiding AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else
        'BGT_OSDG_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_OSDG_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_OSDG_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_overigescheiding);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_paal AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else
        'BGT_PAL_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_PAL_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_PAL_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_paal);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_put AS (
SELECT
    imgeo_put.identificatie_namespace   AS namespace,
    imgeo_put.identificatie_lokaalid    AS lokaalid,
    imgeo_put.objectbegintijd           AS begintijd,
    imgeo_put.objecteindtijd            AS einddtijd,
    imgeo_put.tijdstipregistratie       AS tijdreg,
    imgeo_put.eindregistratie           AS eindreg,
    imgeo_put.lv_publicatiedatum        AS lv_pubdat,
    imgeo_put.bronhouder                AS bronhoud,
    imgeo_put.inonderzoek               AS inonderzk,
    imgeo_put.relatievehoogteligging    AS hoogtelig,
    imgeo_put.bgt_status                AS bgtstatus,
    imgeo_put.plus_status               AS plusstatus,
    imgeo_put.bgt_type                  AS bgttype,
    case
        when bgt_type ='niet-bgt'
        then null
        else 'BGT_PUT_'|| LOWER(
            REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                                 AS BESTANDSNAAM,
    plus_type                           AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_PUT_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_PUT_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                                 AS BESTANDSNAAM_PLUS,
    imgeo_put.geometrie
FROM imgeo.imgeo_put);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_scheiding AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_SDG_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_SDG_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_SDG_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_scheiding);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_SENSOR AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_SSR_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_SSR_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_SSR_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                          AS BESTANDSNAAM_PLUS,
    geometrie                    AS GEOMETRIE
FROM imgeo.IMGEO_SENSOR);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_spoor AS (
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
    else 'BGT_SPR_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_functie ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_functie                AS PLUSFUNCT,
    case
        when bgt_functie ='niet-bgt' and plus_functie is null
        then 'BGTPLUS_SPR_'||'onbekend'
    else
        case
            when bgt_functie ='niet-bgt'
            then 'BGTPLUS_SPR_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_functie ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_spoor);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_straatmeubilair AS (
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
    case
        when bgt_type ='niet-bgt'
        then null
    else 'BGT_SMR_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null
        then 'BGTPLUS_SMR_'||'onbekend'
    else
        case
            when bgt_type ='niet-bgt'
            then 'BGTPLUS_SMR_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_straatmeubilair);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_vegetatieobject AS (
SELECT    
    identificatie_namespace   AS NAMESPACE,
    identificatie_lokaalid    AS LOKAALID,
    objectbegintijd           AS BEGINTIJD,
    objecteindtijd            AS EINDDTIJD,
    tijdstipregistratie       AS TIJDREG,
    eindregistratie           AS EINDREG,
    lv_publicatiedatum        AS LV_PUBDAT,
    bronhouder                AS BRONHOUD,
    inonderzoek               AS INONDERZK,
    relatievehoogteligging    AS HOOGTELIG,
    bgt_status                AS BGTSTATUS,
    plus_status               AS PLUSSTATUS,
    bgt_type                  AS BGTTYPE,
    case
        when bgt_type ='niet-bgt' 
        then null
    else 'BGT_VGT_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                       AS BESTANDSNAAM,
    plus_type                 AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null 
        then 'BGTPLUS_VGT_'||'onbekend' 
        else
            case
                when bgt_type ='niet-bgt' 
                then 'BGTPLUS_VGT_'|| LOWER(
                    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                    plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
            end
    end                       AS BESTANDSNAAM_PLUS,
    geometrie                 AS GEOMETRIE
FROM imgeo.imgeo_vegetatieobject);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_waterinrichtingselement AS (
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
    case
        when bgt_type ='niet-bgt' 
        then null
    else 'BGT_WDI_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null 
        then 'BGTPLUS_WDI_'||'onbekend' 
    else
        case
            when bgt_type ='niet-bgt' 
            then 'BGTPLUS_WDI_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_waterinrichtingselement);

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_weginrichtingselement AS (
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
    case
        when bgt_type ='niet-bgt' 
        then null
    else 'BGT_WGI_'|| LOWER(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        bgt_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
    end                         AS BESTANDSNAAM,
    plus_type                   AS PLUSTYPE,
    case
        when bgt_type ='niet-bgt' and plus_type is null 
        then 'BGTPLUS_WGI_'||'onbekend' 
    else
        case
            when bgt_type ='niet-bgt' 
            then 'BGTPLUS_WGI_'|| LOWER(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                plus_type ,',',''),'/ ',''),':',''),'(',''),')',''),'/','_'),' ','_'))
        end
    end                         AS BESTANDSNAAM_PLUS,
    geometrie                   AS GEOMETRIE
FROM imgeo.imgeo_weginrichtingselement);
