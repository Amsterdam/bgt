\qecho
\qecho "*******************************************************************************"
\qecho "* Aanmaak tabellen BGT-schema IMGEO ...                                       *"
\qecho "*******************************************************************************"
\qecho


\i create_tbl_imgeo.imgeo_functioneelgebied.sql
\i create_tbl_imgeo.bgt_plaatsbepalingspunt.sql
\i create_tbl_imgeo.imgeo_bord.sql
\i create_tbl_imgeo.imgeo_mast.sql
\i create_tbl_imgeo.imgeo_sensor.sql


\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar met aanmaak tabellen BGT-schema IMGEO.                                *"
\qecho "*******************************************************************************"
\qecho
