TRUNCATE TABLE imgeo_controle.VERGELIJK_GML_DB;

INSERT INTO imgeo_controle.vergelijk_gml_db
  (SELECT
     db.tabelnaam           AS tabelnaam,
     gml.aantal             AS aantal_gml,
     db.aantal              AS aantal_db,
     gml.aantal - db.aantal AS verschil
   FROM imgeo_controle.tel_gml gml
     LEFT JOIN imgeo_controle.mapping_gml_db map ON lower(gml.tabelnaam) = lower(map.gmlnaam)
     RIGHT JOIN imgeo_controle.tel_db db ON lower(map.dbnaam) = lower(db.tabelnaam)
   ORDER BY db.tabelnaam);

-- Bovenstaande telt en vergelijkt aantallen rijen in GML- en BGT-/IMGEO-tabellen en vult tabel VERGELIJK_GML_DB
-- in BGT-database:
-- NB. in de BGT-/IMGEO-schema's zijn een aantal Objectklassen die nog niet in de GML download
--     zitten vandaar dat deze leeg zijn in de GML aantallen.
