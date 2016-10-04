
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_bgt_ondersteunendwaterdeel ...              *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_bgt_ondersteunendwaterdeel;

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_ondersteunendwaterdeel
AS
(
SELECT identificatie_namespace     as NAMESPACE
     , identificatie_lokaalid      as LOKAALID
     , objectbegintijd             as BEGINTIJD
     , objecteindtijd              as EINDDTIJD
     , tijdstipregistratie         as TIJDREG     
     , eindregistratie             as EINDREG
     , lv_publicatiedatum          as LV_PUBDAT
     , bronhouder                  as BRONHOUD
     , inonderzoek                 as INONDERZK
     , relatievehoogteligging      as HOOGTELIG
     , bgt_status                  as BGTSTATUS
     , plus_status                 as PLUSSTATUS
     , bgt_type                    as BGTTYPE
     , 'BGT_OWDL_'||
        LOWER( REPLACE(                   
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
                ' ','_') -- vervangen 'spatie' tekens met '_'     
              )                    as BESTANDSNAAM
     , plus_type                   as PLUSTYPE
     , geometrie                   as GEOMETRIE
  FROM imgeo.bgt_ondersteunendwaterdeel)
  ;


\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_bgt_ondersteunendwaterdeel.       *'
\qecho '*******************************************************************************'
\qecho
