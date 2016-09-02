
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_shp_bgt_ongeclassificeerdobject ...         *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_bgt_ongeclassificeerdobject
AS
(
SELECT identificatie_namespace as NAMESPACE
     , identificatie_lokaalid  as LOKAALID
     , objectbegintijd	       as BEGINTIJD
     , objecteindtijd          as EINDDTIJD
     , tijdstipregistratie     as TIJDREG     
     , eindregistratie         as EINDREG
     , lv_publicatiedatum      as LV_PUBDAT
     , bronhouder              as BRONHOUD
     , inonderzoek             as INONDERZK
     , relatievehoogteligging  as HOOGTELIG
     , bgt_status              as BGTSTATUS
     , plus_status             as PLUSSTATUS
	 , CASE 
             when identificatie_namespace ='NL.IMGeo'
             then 'BGT_OOT_ongeclassificeerd'
       END		       
	                           as BESTANDNAAM 
     , geometrie               as geometrie
  FROM imgeo.bgt_ongeclassificeerdobject)
  ;


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_shp_bgt_ongeclassificeerdobject.  *"
\qecho "*******************************************************************************"
\qecho
