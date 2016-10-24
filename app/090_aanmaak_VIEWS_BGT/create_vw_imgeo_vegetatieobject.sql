
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_imgeo_vegetatieobject ...                   *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_imgeo_vegetatieobject;

CREATE OR REPLACE VIEW imgeo_extractie.vw_imgeo_vegetatieobject
AS
(
SELECT    identificatie_namespace   as NAMESPACE
        , identificatie_lokaalid    as LOKAALID
        , objectbegintijd           as BEGINTIJD
        , objecteindtijd            as EINDDTIJD
        , tijdstipregistratie       as TIJDREG     
        , eindregistratie           as EINDREG
        , lv_publicatiedatum        as LV_PUBDAT
        , bronhouder                as BRONHOUD
        , inonderzoek               as INONDERZK
        , relatievehoogteligging    as HOOGTELIG
        , bgt_status                as BGTSTATUS
        , plus_status               as PLUSSTATUS
        , bgt_type                  as BGTTYPE
     , case
        when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
     then null
     else
          'BGT_VGT_'|| -- prefixed toevoegen aan BESTANDSNAAM
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
    end                             as BESTANDSNAAM
     , plus_type                    as PLUSTYPE 
     ,case
    when bgt_type ='niet-bgt' and plus_type is null -- cntr op bgt_type ='niet-bgt' en plus_type is leeg
         then 'BGTPLUS_VGT_'||'onbekend' --prefixed en plustype 'onbekend' in BESTANDSNAAM_plus
         else
            case
            when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt' en plustype is wel gevuld
            then
                 'BGTPLUS_VGT_'|| --prefixed en plustype in BESTANDSNAAM_plus
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
            )end
    end                             as BESTANDSNAAM_PLUS
     , geometrie                    as GEOMETRIE
  FROM imgeo.imgeo_vegetatieobject)
  ;


\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_imgeo_vegetatieobject.            *'
\qecho '*******************************************************************************'
\qecho
