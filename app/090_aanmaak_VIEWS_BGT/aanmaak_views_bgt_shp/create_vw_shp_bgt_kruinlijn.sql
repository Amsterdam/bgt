﻿
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_shp_bgt_kruinlijn ...                       *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_bgt_kruinlijn
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
     , optalud                 as OPTALUD
     , REPLACE (identificatie_namespace ,'NL.IMGeo','BGT_KLN_')||
       LOWER( REPLACE(           	    
		       REPLACE(
				Replace(
					REPLACE(
						REPLACE(
							REPLACE(
								REPLACE (objectklasse_kruinlijn ,',',''),  -- vervangen ',' tekens met niks  
							'/ ',''), -- vervangen '/spatie' tekens met niks 
						':',''), -- vervangen ':' tekens met niks 
					'(',''), -- vervangen '(' tekens met niks 
				')',''), -- vervangen ')' tekens met niks 		
			'/',''), -- vervangen '/' tekens met niks 			
	       ' ','_') -- vervangen 'spatie' tekens met '_' 	
              )       as BESTANDNAAM
     , objectklasse_kruinlijn  as HOORTBIJ
     , geometrie               as GEOMETRIE
  FROM imgeo.bgt_kruinlijn)
  ;


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_shp_bgt_kruinlijn.                *"
\qecho "*******************************************************************************"
\qecho
