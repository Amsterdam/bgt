
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_shp_bgt_openbareruimtelabel ...             *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_shp_bgt_openbareruimtelabel;

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_bgt_openbareruimtelabel
AS
(
SELECT identificatie_namespace as NAMESPACE
     , identificatie_lokaalid  as LOKAALID
     , objectbegintijd         as BEGINTIJD
     , objecteindtijd          as EINDDTIJD
     , tijdstipregistratie     as TIJDREG     
     , eindregistratie         as EINDREG
     , lv_publicatiedatum      as LV_PUBDAT
     , bronhouder              as BRONHOUD
     , inonderzoek             as INONDERZK
     , relatievehoogteligging  as HOOGTELIG
     , bgt_status              as BGTSTATUS
     , plus_status             as PLUSSTATUS
     
     , identificatiebagopr     as BAGOPRID
     , openbareruimtetype      as OPRTYPE
     , REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_LBL_')||
    LOWER( REPLACE(                   
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE (openbareruimtetype ,',',''),  -- vervangen ',' tekens met niks  
                                '/ ',''), -- vervangen '/spatie' tekens met niks 
                            ':',''), -- vervangen ':' tekens met niks 
                        '(',''), -- vervangen '(' tekens met niks 
                    ')',''), -- vervangen ')' tekens met niks         
                '/','_'), -- vervangen '/' tekens met underscore (tbv en/of -> en_of)             
            ' ','_') -- vervangen 'spatie' tekens met '_' teken         
         )                     as BESTANDSNAAM
     , opr_label_tekst         as LABELTEKST
     , opr_label_hoek          as HOEK
     , geometrie               as geometrie
  FROM imgeo.bgt_openbareruimtelabel)
  ;
  

\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_shp_bgt_openbareruimtelabel.      *'
\qecho '*******************************************************************************'
\qecho
