TRUNCATE TABLE imgeo_controle.mapping_gml_db;
COPY imgeo_controle.mapping_gml_db(gmlbestand,gmlnaam,dbnaam,extractieview) FROM '075_mapping.csv' DELIMITER ';' CSV HEADER;
