-- "*
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Naam :                    select_datadictionairy.sql                       *"
-- "*                                                                             *"
-- "* Systeem :                 DATAPUNT                                          *"
-- "*                                                                             *"
-- "* Module :                  BGT (Verwerving)                                  *"
-- "*                                                                             *"
-- "* Schema / Gegevensstroom : imgeo_gml / BGT                                   *"
-- "*                                                                             *"
-- "* Aangeroepen vanuit :      n.v.t.                                            *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Doel :                    genereren datadictonairy schema imgeo             *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* DATAPUNT-BGT versienr :   0.0.1                                             *"
-- "*                                                                             *"
-- "*******************************************************************************"
-- "*                                                                             *"
-- "* Wijzigingsgeschiedenis :                                                    *"
-- "*                                                                             *"
-- "* auteur                    datum        versie   wijziging                   *"
-- "* -----------------------   ----------   ------   --------------------------- "*
-- "* Nico de Graaff, BI        04-04-2016   0.0.1    RC1: initiële aanmaak       *"

-- "*                                                                             *"
-- "*******************************************************************************"


\qecho 
\qecho "*******************************************************************************"
\qecho "* Selecteren tabellen, kolommen, datatypen en nulables van schema imgeo ...  *"
\qecho "*******************************************************************************"
\qecho
--
--
select table_catalog 
,      table_schema  
,      table_name    
,      column_name   
,      data_type
,      case when character_maximum_length is null then numeric_precision
            when numeric_precision is null then character_maximum_length
       end lengte_datatype
,      case when character_maximum_length is null then numeric_precision_radix
            else null
       end precisie_numeriek      
,      is_nullable 
from   information_schema.columns
where  table_schema='imgeo'
order by table_catalog 
,      table_schema  
,      table_name    
,      column_name,ordinal_position
;
--
--
\qecho
\qecho "*******************************************************************************"
\qecho "* Klaar selecteren datadictionairy.                                        *"
\qecho "*******************************************************************************"
\qecho
