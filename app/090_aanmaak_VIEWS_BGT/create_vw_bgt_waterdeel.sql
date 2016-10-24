
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_bgt_waterdeel ...                           *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_bgt_waterdeel;

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_waterdeel
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
     , bgt_type                    as BGTTYPE
     , 'BGT_WDL_'|| 
       LOWER(REPLACE(                   
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
            )                      as BESTANDSNAAM
     , plus_status                 as PLUSSTATUS
     , geometrie                   as GEOMETRIE
  FROM imgeo.bgt_waterdeel)
  ;


\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_bgt_waterdeel.                    *'
\qecho '*******************************************************************************'
\qecho
