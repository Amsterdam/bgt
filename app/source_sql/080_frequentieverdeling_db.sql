TRUNCATE TABLE imgeo_controle.FREQUENTIEVERDELING_DB;

SELECT
  'insert into imgeo_controle.frequentieverdeling_db (select ' || chr(39) || table_name || chr(39) || ' as tabelnaam,'
  || chr(39) || column_name || chr(39) || ' as kolomnaam, ' || column_name || ', count (' || column_name ||
  ') as aantal from ' || table_schema || '.' || table_name || ' group by ' || column_name || ' order by ' || column_name
  || ', aantal );' AS smt
FROM information_schema.columns
WHERE table_schema = 'imgeo'
      AND (table_name LIKE 'imgeo%' OR table_name LIKE 'bgt%')
      AND column_name NOT IN
        (
          'bgt_status', 'eindregistratie', 'geometrie', 'hnr_label_hoek', 'hnr_label_tekst',
          'id_bagvbohoogste_huisnummer', 'id_bagvbolaagste_huisnummer', 'identificatie_lokaalid',
          'identificatie_namespace', 'identificatiebagopr', 'identificatiebagpnd', 'lv_publicatiedatum',
          'objectbegintijd', 'objecteindtijd', 'opr_label_hoek', 'opr_label_tekst', 'plus_status',
          'relatievehoogteligging', 'tijdstipregistratie'
        )
ORDER BY table_schema, table_name, column_name;

--, 'inonderzoek'
-- , 'openbareruimtetype'

-- Bovenstaande geeft de volgende uitvoer in SQL-script: (insert-opdrachten met aantal attribuutwaarden
-- per attribuut van alle bgt-object_tabel in bgt_database):
-- bijvoorbeeld: insert into imgeo_controle.frequentieverdeling_db
--   (select 'bgt_begroeidterreindeel' as tabelnaam,
--           'bgt_fysiekvoorkomen' as kolomnaam,bgt_fysiekvoorkomen ,
--           count (bgt_fysiekvoorkomen)
--    from imgeo.bgt_begroeidterreindeel group by bgt_fysiekvoorkomen order by bgt_fysiekvoorkomen );
-- enzovoorts, gevolgd door een COMMIT;

-- ######

-- Draaien van het script levert de volgende uitvoer in tabel imgeo_controle.frequentieverdeling_db:
-- frequentieverdelingen per attribuut per BGT-/IMGEO-tabel (= objectklasse) in IMGEO-schema in BGT-database