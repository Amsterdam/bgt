--- BGT: selecteer de verschillen in (frequentieverdeelde) kolommen
--- in de frequentieverdelingen GML versus DB.
--- RY, 16 aug. 2016
---

SELECT DISTINCT
  'GML'         AS bron,
  gml.tabelnaam AS gml_tabelnaam,
  map.dbnaam    AS db_tabelnaam,
  gml.kolomnaam /*, db.kolomwaarde */
FROM imgeo_controle.frequentieverdeling_gml gml
  , imgeo_controle.mapping_gml_db map
WHERE lower(map.gmlnaam) = lower(gml.tabelnaam)
      AND (lower(gml.tabelnaam), lower(map.dbnaam), gml.kolomnaam) NOT IN (SELECT
                                                                             lower(map.gmlnaam),
                                                                             lower(db.tabelnaam),
                                                                             db.kolomnaam /*, db.kolomwaarde */
                                                                           FROM imgeo_controle.frequentieverdeling_db db
                                                                             , imgeo_controle.mapping_gml_db map
                                                                           WHERE lower(map.dbnaam) = lower(db.tabelnaam)
)
---
UNION
---
SELECT DISTINCT
  'DB'         AS bron,
  map.gmlnaam  AS gml_tabelnaam,
  db.tabelnaam AS db_tabelnaam,
  db.kolomnaam /*, db.kolomwaarde*/
FROM imgeo_controle.frequentieverdeling_db db
  , imgeo_controle.mapping_gml_db map
WHERE lower(map.dbnaam) = lower(db.tabelnaam)
      AND (lower(map.gmlnaam), lower(db.tabelnaam), db.kolomnaam) NOT IN (SELECT
                                                                            lower(gml.tabelnaam),
                                                                            lower(map.gmlnaam),
                                                                            gml.kolomnaam /*, db.kolomwaarde */
                                                                          FROM
                                                                            imgeo_controle.frequentieverdeling_gml gml
                                                                            , imgeo_controle.mapping_gml_db map
                                                                          WHERE
                                                                            lower(map.gmlnaam) = lower(gml.tabelnaam)
)
ORDER BY gml_tabelnaam, db_tabelnaam, kolomnaam /*, db.kolomwaarde */;
