
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_shp_bgt_overbruggingsdeel ...               *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_shp_bgt_overbruggingsdeel;

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_bgt_overbruggingsdeel
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
     , plus_type                   as PLUSTYPE
     , REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_ODL_overbruggingsdeel')
                                   as BESTANDSNAAM
     , hoortbijtypeoverbrugging    as HOORTBIJ
     , overbruggingisbeweegbaar    as ISBEWEEGB
     , geometrie                   as GEOMETRIE
  FROM imgeo.bgt_overbruggingsdeel)
  ;


\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_shp_bgt_overbruggingsdeel.        *'
\qecho '*******************************************************************************'
\qecho
