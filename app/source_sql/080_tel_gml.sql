TRUNCATE TABLE imgeo_controle.TEL_GML;

SELECT 'insert into imgeo_controle.tel_gml (select ' || chr(39) || table_name || chr(39) || ' as tabelnaam,' ||
       ' count(*) as aantal from ' || 'imgeo_gml.' || table_name || ');' AS smt
FROM information_schema.tables
WHERE table_schema = 'imgeo_gml'
ORDER BY table_name;