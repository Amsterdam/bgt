
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_imgeo_overigbouwwerk ...                    *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_imgeo_overigbouwwerk;

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_overigbouwwerk AS 
 SELECT imgeo_overigbouwwerk.identificatie_namespace AS namespace,
    imgeo_overigbouwwerk.identificatie_lokaalid AS lokaalid,
    imgeo_overigbouwwerk.objectbegintijd AS begintijd,
    imgeo_overigbouwwerk.objecteindtijd AS einddtijd,
    imgeo_overigbouwwerk.tijdstipregistratie AS tijdreg,
    imgeo_overigbouwwerk.eindregistratie AS eindreg,
    imgeo_overigbouwwerk.lv_publicatiedatum AS lv_pubdat,
    imgeo_overigbouwwerk.bronhouder AS bronhoud,
    imgeo_overigbouwwerk.inonderzoek AS inonderzk,
    imgeo_overigbouwwerk.relatievehoogteligging AS hoogtelig,
    imgeo_overigbouwwerk.bgt_status AS bgtstatus,
    imgeo_overigbouwwerk.plus_status AS plusstatus,
    imgeo_overigbouwwerk.bgt_type AS bgttype
    , case
        when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
     then null
     else
          'BGT_OBW_'|| -- prefixed toevoegen aan BESTANDSNAAM
    LOWER(        REPLACE(                   
                REPLACE(
                    Replace(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE (bgt_type ,',',''),  -- vervangen ',' tekens met niks  
                                '/ ',''), -- vervangen '/spatie' tekens met niks 
                            ':',''), -- vervangen ':' tekens met niks 
                        '(',''), -- vervangen '(' tekens met niks 
                    ')',''), -- vervangen ')' tekens met niks         
                '/','_'), -- vervangen '/' tekens met underscore (tbv en/of -> en_of)             
            ' ','_') -- vervangen 'spatie' tekens met '_' teken         
             )
    end                  as BESTANDSNAAM
    ,imgeo_overigbouwwerk.plus_type AS plustype
    ,case
    when bgt_type ='niet-bgt' and plus_type is null -- cntr op bgt_type ='niet-bgt' en plus_type is leeg
         then 'BGTPLUS_OBW_'||'onbekend' --prefixed en plustype 'onbekend' in BESTANDSNAAM_plus
         else
            case
            when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt' en plustype is wel gevuld
            then
                 'BGTPLUS_OBW_'|| --prefixed en plustype in BESTANDSNAAM_plus
        LOWER(        REPLACE(                   
                    REPLACE(
                        Replace(
                            REPLACE(
                                REPLACE(
                                    REPLACE(
                                        REPLACE (plus_type ,',',''),  -- vervangen ',' tekens met niks  
                                    '/ ',''), -- vervangen '/spatie' tekens met niks 
                                ':',''), -- vervangen ':' tekens met niks 
                            '(',''), -- vervangen '(' tekens met niks 
                        ')',''), -- vervangen ')' tekens met niks         
                    '/','_'), -- vervangen '/' tekens met underscore (tbv en/of -> en_of)             
                ' ','_') -- vervangen 'spatie' tekens met '_'     
            )
		 end
    end                         as BESTANDSNAAM_PLUS
   , imgeo_overigbouwwerk.geometrie
   FROM imgeo.imgeo_overigbouwwerk;
   

\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_imgeo_overigbouwwerk.             *'
\qecho '*******************************************************************************'
\qecho
