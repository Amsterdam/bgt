TRUNCATE TABLE imgeo_controle.FREQUENTIEVERDELING_GML;

SELECT
  'insert into imgeo_controle.frequentieverdeling_gml (select ' || chr(39) || table_name || chr(39) || ' as tabelnaam,'
  || chr(39) || column_name || chr(39) || ' as kolomnaam, ' || column_name || ', count (' || column_name ||
  ') as aantal from ' || table_schema || '.' || table_name || ' group by ' || column_name || ' order by ' || column_name
  || ', aantal );' AS smt
FROM information_schema.columns
WHERE table_schema = 'imgeo_gml'
      AND column_name IN
        (
          'begroeidterreindeeloptalud', 'bgt_fysiekvoorkomen', 'bgt_type', 'bronhouder', 'class', 'function',
          'hoortbijtypeoverbrugging', 'onbegroeidterreindeeloptalud', 'ondersteunendwegdeeloptalud',
          'openbareruimtetype', 'overbruggingisbeweegbaar', 'plus_functieondersteunendwegdeel',
          'plus_functiewegdeel', 'plus_fysiekvoorkomen', 'plus_fysiekvoorkomenondersteunendwegdeel',
          'plus_fysiekvoorkomenwegdeel', 'plus_type', 'plus_typegebouwinstallatie', 'surfacematerial', 'wegdeeloptalud'
        )
ORDER BY table_schema, table_name, column_name;

-- , 'identificatiebagopr'
-- , 'identificatiebagpnd'

-- Bovenstaande geeft de volgende uitvoer (insert_scripts met aantal attribuutwaarden per attribuut van alle
-- gmltabellen in bgt_database):
--  bv insert into imgeo_gml.cntrl_gml_attribuutwaarden
--   (select 'auxiliarytrafficarea' as tabelnaam,'function' as kolomnaam,function ,
--      count (function) from imgeo_gml.auxiliarytrafficarea group by function order by function);
--  enzovoorts
