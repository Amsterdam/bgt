
\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak view imgeo_extractie.vw_dgn_bgt_wegdeel ...                         *"
\qecho "*******************************************************************************"
\qecho


-- Schema: imgeo_extractie

-- \pset tuples_only

CREATE OR REPLACE VIEW imgeo_extractie.vw_dgn_bgt_wegdeel AS 
 SELECT bgt_wegdeel.identificatie_namespace AS namespace,
    bgt_wegdeel.identificatie_lokaalid AS lokaalid,
    bgt_wegdeel.bgt_functie AS bgtfunctie,
		case
			when bgt_functie ='niet-bgt' -- cntr op bgt_type ='niet-bgt'
		 then null

		 else
		      'BGT_WGL_'|| -- prefixed toevoegen aan bestandnaam
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
		end	  			as BESTANDNAAM,
    bgt_wegdeel.geometrie
   FROM   imgeo.bgt_wegdeel  A, pdt_kaartblad  B
   WHERE  B.big_id = 1   and
          st_intersect( A.geometrie, B.geometrie) <> null 
/*		  or
		  left (st_intersect( A.geometrie, B.geometrie),5) <>  'POINT'  or
  		  left (st_intersect( A.geometrie, B.geometrie),4) <>  'LINE'
*/
		  ;
		  


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak view imgeo_extractie.vw_dgn_bgt_wegdeel.                  *"
\qecho "*******************************************************************************"
\qecho
