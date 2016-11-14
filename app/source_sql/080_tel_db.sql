TRUNCATE TABLE imgeo_controle.TEL_DB;

SELECT 'insert into imgeo_controle.tel_db (select ' || chr(39) || table_name || chr(39) || ' as tabelnaam,' ||
       ' count(*) as aantal from ' || 'imgeo.' || table_name || ');' AS smt
FROM information_schema.tables
WHERE table_schema = 'imgeo' AND (table_name LIKE 'bgt_%' OR table_name LIKE 'imgeo_%')
ORDER BY table_name;