
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_shp_imgeo_put ...                           *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_imgeo_put AS 
 SELECT imgeo_put.identificatie_namespace AS namespace,
    imgeo_put.identificatie_lokaalid AS lokaalid,
    imgeo_put.objectbegintijd AS begintijd,
    imgeo_put.objecteindtijd AS einddtijd,
    imgeo_put.tijdstipregistratie AS tijdreg,
    imgeo_put.eindregistratie AS eindreg,
    imgeo_put.lv_publicatiedatum AS lv_pubdat,
    imgeo_put.bronhouder AS bronhoud,
    imgeo_put.inonderzoek AS inonderzk,
    imgeo_put.relatievehoogteligging AS hoogtelig,
    imgeo_put.bgt_status AS bgtstatus,
    imgeo_put.plus_status AS plusstatus,
    imgeo_put.bgt_type AS bgttype
 

    , case
		when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
	 then null

	 else
	      'BGT_PUT_'|| -- prefixed toevoegen aan bestandnaam
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
		 then 'BGTPLUS_PUT_'||'onbekend' --prefixed en plustype 'onbekend' in bestandnaam_plus
		 else
			case
			when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt' en plustype is wel gevuld
			then
			     'BGTPLUS_PUT_'|| --prefixed en plustype in bestandnaam_plus
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
    ,imgeo_put.geometrie
   FROM imgeo.imgeo_put;


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_shp_imgeo_put.                    *"
\qecho "*******************************************************************************"
\qecho
