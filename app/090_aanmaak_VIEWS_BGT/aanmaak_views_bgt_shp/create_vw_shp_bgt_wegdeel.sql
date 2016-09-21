
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_shp_bgt_wegdeel ...                         *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_shp_bgt_wegdeel;

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_bgt_wegdeel AS 
 SELECT bgt_wegdeel.identificatie_namespace AS namespace,
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
            when bgt_functie ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
            then null
        else 'BGT_WGL_'|| -- prefixed toevoegen aan BESTANDSNAAM
             LOWER (REPLACE(                   
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(
                                        REPLACE (bgt_functie ,',',''),  -- vervangen ',' tekens met niks  
                                    '/ ',''), -- vervangen '/spatie' tekens met niks 
                                ':',''), -- vervangen ':' tekens met niks 
                            '(',''), -- vervangen '(' tekens met niks 
                        ')',''), -- vervangen ')' tekens met niks         
                    '/','_'), -- vervangen '/' tekens met underscore (tbv en/of -> en_of)             
                ' ','_') -- vervangen 'spatie' tekens met '_' teken         
                   )
        end                                 as BESTANDSNAAM,
    bgt_wegdeel.bgt_fysiekvoorkomen         AS bgtfysvkn,
    bgt_wegdeel.optalud                     as optalud,
    bgt_wegdeel.plus_functie                AS plusfunct,
    bgt_wegdeel.plus_fysiekvoorkomen        AS plusfysvkn,
    bgt_wegdeel.geometrie                   as geometrie
   FROM imgeo.bgt_wegdeel;
   

\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_shp_bgt_wegdeel.                  *'
\qecho '*******************************************************************************'
\qecho
