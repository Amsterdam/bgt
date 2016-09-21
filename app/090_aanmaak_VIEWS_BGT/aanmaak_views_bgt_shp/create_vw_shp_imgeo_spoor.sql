
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_shp_imgeo_spoor ...                         *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_shp_imgeo_spoor;

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_imgeo_spoor
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
     , bgt_functie                 as BGTFUNCTIE
     , case
            when bgt_functie ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
         then null
         else
              'BGT_SPR_'|| -- prefixed toevoegen aan BESTANDSNAAM
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
        end                        as BESTANDSNAAM
     , plus_functie                as PLUSFUNCT
     ,case
    when bgt_functie ='niet-bgt' and plus_functie is null -- cntr op bgt_type ='niet-bgt' en plus_type is leeg
         then 'BGTPLUS_SDG_'||'onbekend' --prefixed en plustype 'onbekend' in BESTANDSNAAM_plus
         else
            case
            when bgt_functie ='niet-bgt' -- cntr op bgt_type ='niet-bgt' en plustype is wel gevuld
            then
                 'BGTPLUS_SDG_'|| --prefixed en plustype in BESTANDSNAAM_plus
        LOWER(        REPLACE(                   
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(
                                    REPLACE(
                                        REPLACE (plus_functie ,',',''),  -- vervangen ',' tekens met niks  
                                    '/ ',''), -- vervangen '/spatie' tekens met niks 
                                ':',''), -- vervangen ':' tekens met niks 
                            '(',''), -- vervangen '(' tekens met niks 
                        ')',''), -- vervangen ')' tekens met niks         
                    '/','_'), -- vervangen '/' tekens met underscore (tbv en/of -> en_of)             
                ' ','_') -- vervangen 'spatie' tekens met '_'     
            )end
    end                            as BESTANDSNAAM_PLUS
     , geometrie                   as GEOMETRIE
  FROM imgeo.imgeo_spoor)
  ;


\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_shp_imgeo_spoor.                  *'
\qecho '*******************************************************************************'
\qecho
