
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_shp_imgeo_bak ...                           *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only

CREATE OR REPLACE VIEW imgeo_extractie.vw_shp_imgeo_bak AS 
 SELECT imgeo_bak.identificatie_namespace AS namespace,
    imgeo_bak.identificatie_lokaalid AS lokaalid,
    imgeo_bak.objectbegintijd AS begintijd,
    imgeo_bak.objecteindtijd AS einddtijd,
    imgeo_bak.tijdstipregistratie AS tijdreg,
    imgeo_bak.eindregistratie AS eindreg,
    imgeo_bak.lv_publicatiedatum AS lv_pubdat,
    imgeo_bak.bronhouder AS bronhoud,
    imgeo_bak.inonderzoek AS inonderzk,
    imgeo_bak.relatievehoogteligging AS hoogtelig,
    imgeo_bak.bgt_status AS bgtstatus,
    imgeo_bak.plus_status AS plusstatus,
    imgeo_bak.bgt_type AS bgttype
    , case
		when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
	 then null

	 else
	      'BGT_BAK_'|| -- prefixed toevoegen aan bestandnaam
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
		 then 'BGTPLUS_BAK_'||'onbekend' --prefixed en plustype 'onbekend' in bestandnaam_plus
		 else
			case
			when bgt_type ='niet-bgt' -- cntr op bgt_type ='niet-bgt' en plustype is wel gevuld
			then
			     'BGTPLUS_BAK_'|| --prefixed en plustype in bestandnaam_plus
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
    ,imgeo_bak.geometrie 	AS GEOMETRIE
   FROM imgeo.imgeo_bak;


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_shp_imgeo_bak.                    *"
\qecho "*******************************************************************************"
\qecho
