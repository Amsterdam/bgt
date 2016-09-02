
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_shp_bgt_ondersteunendwegdeel ...            *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_bgt_ondersteunendwegdeel
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
     , bgt_functie 		   as BGTFUNCTIE

     ,case
			when bgt_functie ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
		 then null

		 else
		      'BGT_OWGL_'|| -- prefixed toevoegen aan bestandnaam
			    LOWER (REPLACE(           	    
					REPLACE(
						Replace(
							REPLACE(
								REPLACE(
									REPLACE(
										REPLACE (bgt_functie ,',',''),  -- vervangen ',' tekens met niks  
									'/ ',''), -- vervangen '/spatie' tekens met niks 
								':',''), -- vervangen ':' tekens met niks 
							'(',''), -- vervangen '(' tekens met niks 
						')',''), -- vervangen ')' tekens met niks 		
					'/',''), -- vervangen '/' tekens met niks 			
				' ','_') -- vervangen 'spatie' tekens met '_' teken 		
				)
		end	  	   as BESTANDNAAM
     , bgt_fysiekvoorkomen	   as BGTFYSVKN
     , optalud                     as OPTALUD
     , plus_functie 	  	   as PLUSFUNCT
     , plus_fysiekvoorkomen    	   as PLUSFYSVKN
     , geometrie                   as GEOMETRIE
  FROM imgeo.bgt_ondersteunendwegdeel)
  ;


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_shp_bgt_ondersteunendwegdeel.     *"
\qecho "*******************************************************************************"
\qecho
