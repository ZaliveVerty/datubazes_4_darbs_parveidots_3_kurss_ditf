CREATE TABLE university_xml (
    id NUMBER PRIMARY KEY,
    xml_data XMLTYPE
);

CREATE TABLE university_json (
    id NUMBER PRIMARY KEY,
    json_data CLOB CHECK (json_data IS JSON)
);


CREATE TYPE fakultate_type AS OBJECT (
    fakultates_id NUMBER,
    nosaukums VARCHAR2(100)
);
/

CREATE TYPE studiju_programma_type AS OBJECT (
    studiju_id NUMBER,
    nosaukums VARCHAR2(100),
    fakultates_id NUMBER
);
/

CREATE TYPE studiju_kurss_type AS OBJECT (
    kursa_id NUMBER,
    nosaukums VARCHAR2(100),
    studiju_id NUMBER
);
/

CREATE TYPE modulis_type AS OBJECT (
    modula_id NUMBER,
    nosaukums VARCHAR2(100),
    kursa_id NUMBER
);
/

CREATE TYPE temats_type AS OBJECT (
    temata_id NUMBER,
    nosaukums VARCHAR2(100),
    apraksts VARCHAR2(200),
    kreditpunkti NUMBER,
    stundu_skaits NUMBER,
    modula_id NUMBER
);
/

CREATE TABLE fakultate OF fakultate_type (
    PRIMARY KEY (fakultates_id)
);

CREATE TABLE studiju_programma OF studiju_programma_type (
    PRIMARY KEY (studiju_id),
    FOREIGN KEY (fakultates_id) REFERENCES fakultate
);

CREATE TABLE studiju_kurss OF studiju_kurss_type (
    PRIMARY KEY (kursa_id),
    FOREIGN KEY (studiju_id) REFERENCES studiju_programma
);

CREATE TABLE modulis OF modulis_type (
    PRIMARY KEY (modula_id),
    FOREIGN KEY (kursa_id) REFERENCES studiju_kurss
);

CREATE TABLE temats OF temats_type (
    PRIMARY KEY (temata_id),
    FOREIGN KEY (modula_id) REFERENCES modulis
);