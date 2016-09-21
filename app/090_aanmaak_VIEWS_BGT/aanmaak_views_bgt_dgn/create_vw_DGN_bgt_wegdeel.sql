
\qecho
\qecho '*******************************************************************************'
\qecho '* Aanmaak view imgeo_extractie.vw_dgn_bgt_wegdeel ...                         *'
\qecho '*******************************************************************************'
\qecho


-- Schema: imgeo_extractie

DROP VIEW imgeo_extractie.vw_dgn_bgt_wegdeel;

CREATE OR REPLACE VIEW imgeo_extractie.vw_dgn_bgt_wegdeel AS 
 SELECT 
        A.identificatie_lokaalid        as  lokaalid,
        A.bgt_functie                   as  bgtfunctie,
        A.relatievehoogteligging        as  relatievehoogteligging,
		A.geometrie                     as  geometrie_wegdeel
 FROM   imgeo.bgt_wegdeel    A
--   , 
--          imgeo.pdt_kaartblad  B
--   WHERE
--          ST_Intersection (A.geometrie, B.geometrie) <> NULL 
--             is binnen FME vervangen door FME CLIPPER transformer
--             reden DGN's zijn images zonder objecten en daardoor met een Clipper te Transformeren
-- limit  500
;


\qecho
\qecho '*******************************************************************************'
\qecho '* Klaar met aanmaak view imgeo_extractie.vw_dgn_bgt_wegdeel.                  *'
\qecho '*******************************************************************************'
\qecho
