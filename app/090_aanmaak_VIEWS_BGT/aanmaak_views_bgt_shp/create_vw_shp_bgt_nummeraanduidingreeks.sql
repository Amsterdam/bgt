
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_shp_bgt_nummeraanduidingreeks ...           *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_bgt_nummeraanduidingreeks
AS
(
SELECT identificatie_namespace     as NAMESPACE
     , identificatie_lokaalid      as LOKAALID
     , objectbegintijd	           as BEGINTIJD
     , objecteindtijd              as EINDDTIJD
     , tijdstipregistratie         as TIJDREG     
     , eindregistratie             as EINDREG
     , lv_publicatiedatum          as LV_PUBDAT
     , bronhouder                  as BRONHOUD
     , inonderzoek                 as INONDERZK
     , relatievehoogteligging      as HOOGTELIG
     , bgt_status                  as BGTSTATUS
     , plus_status                 as PLUSSTATUS
     , REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_LBL_nummeraanduidingreeks')
					               as BESTANDNAAM 
     , identificatiebagpnd         as BAGPNDID
     , id_bagvbolaagste_huisnummer as BAGVBOLGST
     , id_bagvbohoogste_huisnummer as BAGVBOHGST
     , hnr_label_tekst             as LABELTEKST
     , hnr_label_hoek              as HOEK
     , geometrie                   as GEOMETRIE
  FROM imgeo.bgt_nummeraanduidingreeks)
  ;
  

\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_shp_bgt_nummeraanduidingreeks.    *"
\qecho "*******************************************************************************"
\qecho
