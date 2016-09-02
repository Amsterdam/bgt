
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_shp_IMGEO_SENSOR ...                        *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_IMGEO_SENSOR
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
     , bgt_type 		   as BGTTYPE

     , case
		when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
	 then null

	 else
	      'BGT_SSR_'|| -- prefixed toevoegen aan bestandnaam
	LOWER(		REPLACE(           	    
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
				'/',''), -- vervangen '/' tekens met niks 			
			' ','_') -- vervangen 'spatie' tekens met '_' teken 		
             )
	end	  			as BESTANDNAAM
     , plus_type 		   as PLUSTYPE 

     ,case
	when bgt_type ='niet-bgt' and plus_type is null -- cntr op bgt_type ='niet-bgt' en plus_type is leeg
		 then 'BGTPLUS_SSR_'||'onbekend' --prefixed en plustype 'onbekend' in bestandnaam_plus
		 else
			case
			when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt' en plustype is wel gevuld
			then
			     'BGTPLUS_SSR_'|| --prefixed en plustype in bestandnaam_plus
		LOWER(		REPLACE(           	    
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
					'/',''), -- vervangen '/' tekens met niks 			
				' ','_') -- vervangen 'spatie' tekens met '_' 	
			)end
	end 						as BESTANDNAAM_PLUS 
    , geometrie                   as GEOMETRIE
  FROM imgeo.IMGEO_SENSOR)
  ;


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_shp_IMGEO_SENSOR.                 *"
\qecho "*******************************************************************************"
\qecho
