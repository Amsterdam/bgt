--- BGT: selecteer alle kolommen
--- in de frequentieverdelingen GML en DB.
--- RY, 16 aug. 2016
---

select   distinct 'DB' as bron, map.gmlnaam as gml_tabelnaam, db.tabelnaam as db_tabelnaam, db.kolomnaam /*, db.kolomwaarde*/
from     imgeo_controle.frequentieverdeling_db  db
,        imgeo_controle.mapping_gml_db          map
WHERE    lower(map.dbnaam) = lower(db.tabelnaam)
--
UNION
--
select   distinct 'GML' as bron, gml.tabelnaam as gml_tabelnaam, map.dbnaam as db_tabelnaam, gml.kolomnaam /*, db.kolomwaarde*/
from     imgeo_controle.frequentieverdeling_gml gml
,        imgeo_controle.mapping_gml_db          map
WHERE    lower(map.gmlnaam) = lower(gml.tabelnaam)
ORDER by gml_tabelnaam, db_tabelnaam, kolomnaam /*, db.kolomwaarde*/ ;