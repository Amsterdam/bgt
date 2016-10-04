
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_bgt_tunneldeel ...                          *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW IF EXISTS imgeo_extractie.vw_bgt_tunneldeel;

CREATE OR REPLACE VIEW imgeo_extractie.vw_bgt_tunneldeel
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
     , REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_TDL_tunneldeel')
                                   as BESTANDSNAAM 
     , geometrie                   as GEOMETRIE
  FROM imgeo.bgt_tunneldeel)
  ;


\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_bgt_tunneldeel.                   *'
\qecho '*******************************************************************************'
\qecho
