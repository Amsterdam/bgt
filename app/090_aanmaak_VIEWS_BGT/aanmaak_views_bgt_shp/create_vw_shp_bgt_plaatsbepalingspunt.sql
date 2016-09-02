
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_shp_BGT_PLAATSBEPALINGSPUNT ...             *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only


CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_BGT_PLAATSBEPALINGSPUNT
AS
(
SELECT 	identificatie_namespace     	as NAMESPACE
	, identificatie_lokaalid    	as LOKAALID
	, nauwkeurigheid 		AS NAUWKEURIG 
	, datum_inwinning 		AS DAT_INWINN	
	, inwinnende_instantie 		AS INW_INSTAN
	, inwinningsmethode_id 		AS INW_METHID
	, REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_PPT')
					           as BESTANDNAAM 
	, geometrie                   	AS GEOMETRIE
  FROM imgeo.BGT_PLAATSBEPALINGSPUNT)
  ;


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_shp_BGT_PLAATSBEPALINGSPUNT.      *"
\qecho "*******************************************************************************"
\qecho
