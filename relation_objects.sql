-- RESET

DELETE FROM temats;
DELETE FROM modulis;
DELETE FROM studiju_kurss;
DELETE FROM studiju_programma;
DELETE FROM fakultate;

-- XML

INSERT INTO fakultate 
SELECT fakultate_type(
    TO_NUMBER(fakultate.value_id),
    fakultate.value_name
)
FROM university_xml x,
XMLTABLE('/universitate/fakultate' 
    PASSING x.xml_data
    COLUMNS 
        value_id VARCHAR2(10) PATH '@fakultates_id',
        value_name VARCHAR2(100) PATH '@nosaukums',
        xml_content XMLTYPE PATH '.') fakultate;


INSERT INTO studiju_programma
SELECT studiju_programma_type(
    TO_NUMBER(programma.value_id),
    programma.value_name,
    TO_NUMBER(fakultate.value_id)
)
FROM university_xml x,
XMLTABLE('/universitate/fakultate' 
    PASSING x.xml_data
    COLUMNS 
        value_id VARCHAR2(10) PATH '@fakultates_id',
        xml_content XMLTYPE PATH '.') fakultate,
XMLTABLE('fakultate/studiju_programma'
    PASSING fakultate.xml_content
    COLUMNS 
        value_id VARCHAR2(10) PATH '@studiju_id',
        value_name VARCHAR2(100) PATH '@nosaukums') programma;


INSERT INTO studiju_kurss
SELECT studiju_kurss_type(
    TO_NUMBER(kurss.value_id),
    kurss.value_name,
    TO_NUMBER(programma.value_id)
)
FROM university_xml x,
XMLTABLE('/universitate/fakultate/studiju_programma' 
    PASSING x.xml_data
    COLUMNS 
        value_id VARCHAR2(10) PATH '@studiju_id',
        xml_content XMLTYPE PATH '.') programma,
XMLTABLE('studiju_programma/studiju_kurss'
    PASSING programma.xml_content
    COLUMNS 
        value_id VARCHAR2(10) PATH '@kursa_id',
        value_name VARCHAR2(100) PATH '@nosaukums') kurss;


INSERT INTO modulis
SELECT modulis_type(
    TO_NUMBER(modulis.value_id),
    modulis.value_name,
    TO_NUMBER(kurss.value_id)
)
FROM university_xml x,
XMLTABLE('/universitate/fakultate/studiju_programma/studiju_kurss' 
    PASSING x.xml_data
    COLUMNS 
        value_id VARCHAR2(10) PATH '@kursa_id',
        xml_content XMLTYPE PATH '.') kurss,
XMLTABLE('studiju_kurss/modulis'
    PASSING kurss.xml_content
    COLUMNS 
        value_id VARCHAR2(10) PATH '@modula_id',
        value_name VARCHAR2(100) PATH '@nosaukums') modulis;


INSERT INTO temats
SELECT temats_type(
    TO_NUMBER(temats.value_id),
    temats.value_name,
    temats.value_apraksts,
    TO_NUMBER(temats.value_kreditpunkti),
    TO_NUMBER(temats.value_stundu_skaits),
    TO_NUMBER(modulis.value_id)
)
FROM university_xml x,
XMLTABLE('/universitate/fakultate/studiju_programma/studiju_kurss/modulis' 
    PASSING x.xml_data
    COLUMNS 
        value_id VARCHAR2(10) PATH '@modula_id',
        xml_content XMLTYPE PATH '.') modulis,
XMLTABLE('modulis/temats'
    PASSING modulis.xml_content
    COLUMNS 
        value_id VARCHAR2(10) PATH '@temata_id',
        value_name VARCHAR2(100) PATH '@nosaukums',
        value_apraksts VARCHAR2(100) PATH 'apraksts/text()',
        value_kreditpunkti VARCHAR2(10) PATH 'kreditpunkti/text()',
        value_stundu_skaits VARCHAR2(10) PATH 'stundu_skaits/text()') temats;

-- JSON

INSERT INTO fakultate 
SELECT fakultate_type(
    TO_NUMBER(fakultates_id),
    nosaukums
)
FROM university_json j,
JSON_TABLE(j.json_data, '$.universitate.fakultate[*]' 
    COLUMNS (
        fakultates_id VARCHAR2(10) PATH '$.fakultates_id',
        nosaukums VARCHAR2(100) PATH '$.nosaukums'
    )
);


INSERT INTO studiju_programma
SELECT studiju_programma_type(
    TO_NUMBER(studiju_id),
    nosaukums,
    TO_NUMBER(fakultatas_id)
)
FROM university_json j,
JSON_TABLE(j.json_data, '$.universitate.fakultate[*]' 
    COLUMNS (
        fakultatas_id VARCHAR2(10) PATH '$.fakultates_id',
        NESTED PATH '$.studiju_programma[*]' COLUMNS (
            studiju_id VARCHAR2(10) PATH '$.studiju_id',
            nosaukums VARCHAR2(100) PATH '$.nosaukums'
        )
    )
);
        

INSERT INTO studiju_kurss
SELECT studiju_kurss_type(
    TO_NUMBER(kursa_id),
    nosaukums,
    TO_NUMBER(programmas_id)
)
FROM university_json j,
JSON_TABLE(j.json_data, '$.universitate.fakultate.studiju_programma[*]' 
    COLUMNS (
        programmas_id VARCHAR2(10) PATH '$.studiju_id',
        NESTED PATH '$.studiju_kurss[*]' COLUMNS (
            kursa_id VARCHAR2(10) PATH '$.kursa_id',
            nosaukums VARCHAR2(100) PATH '$.nosaukums'
        )
    )
);
        
        
INSERT INTO modulis
SELECT modulis_type(
    TO_NUMBER(modula_id),
    nosaukums,
    TO_NUMBER(kursa_id)
)
FROM university_json j,
JSON_TABLE(j.json_data, '$.universitate.fakultate.studiju_programma.studiju_kurss[*]' 
    COLUMNS (
        kursa_id VARCHAR2(10) PATH '$.kursa_id',
        NESTED PATH '$.modulis[*]' COLUMNS (
            modula_id VARCHAR2(10) PATH '$.modula_id',
            nosaukums VARCHAR2(100) PATH '$.nosaukums'
        )
    )
);


INSERT INTO temats
SELECT temats_type(
    TO_NUMBER(temata_id),
    nosaukums,
    apraksts,
    TO_NUMBER(kreditpunkti),
    TO_NUMBER(stundu_skaits),
    TO_NUMBER(modula_id)
)
FROM university_json j,
JSON_TABLE(j.json_data, '$.universitate.fakultate.studiju_programma.studiju_kurss.modulis[*]' 
    COLUMNS (
        modula_id VARCHAR2(10) PATH '$.modula_id',
        NESTED PATH '$.temats[*]' COLUMNS (
            temata_id VARCHAR2(10) PATH '$.temata_id',
            nosaukums VARCHAR2(100) PATH '$.nosaukums',
            apraksts VARCHAR2(100) PATH '$.apraksts',
            kreditpunkti VARCHAR2(10) PATH '$.kreditpunkti',
            stundu_skaits VARCHAR2(10) PATH '$.stundu_skaits'
        )
    )
);
