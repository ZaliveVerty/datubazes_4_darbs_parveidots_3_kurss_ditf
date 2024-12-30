INSERT INTO university_xml (id, xml_data)
SELECT 1, XMLTYPE(BFILENAME('XML_DIR', 'university.xml'), nls_charset_id('AL32UTF8'))
FROM dual;

DECLARE
  l_bfile  BFILE;
  l_clob   CLOB;
  l_dest_offset INTEGER := 1;
  l_src_offset  INTEGER := 1;
  l_lang_context INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
  l_warning      INTEGER;
BEGIN
  DBMS_LOB.CREATETEMPORARY(l_clob, TRUE);
  l_bfile := BFILENAME('XML_DIR', 'university.json');
  
  DBMS_LOB.OPEN(l_bfile, DBMS_LOB.LOB_READONLY);
  DBMS_LOB.LOADCLOBFROMFILE(
    dest_lob      => l_clob,
    src_bfile     => l_bfile,
    amount        => DBMS_LOB.GETLENGTH(l_bfile),
    dest_offset   => l_dest_offset,
    src_offset    => l_src_offset,
    bfile_csid    => DBMS_LOB.DEFAULT_CSID,
    lang_context  => l_lang_context,
    warning       => l_warning
  );
  
  INSERT INTO university_json (id, json_data)
  VALUES (1, l_clob);
  
  DBMS_LOB.CLOSE(l_bfile);
  DBMS_LOB.FREETEMPORARY(l_clob);
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF DBMS_LOB.ISOPEN(l_bfile) = 1 THEN
      DBMS_LOB.CLOSE(l_bfile);
    END IF;
    IF DBMS_LOB.ISTEMPORARY(l_clob) = 1 THEN
      DBMS_LOB.FREETEMPORARY(l_clob);
    END IF;
    RAISE;
END;
/

INSERT INTO university_xml (id, xml_data)
VALUES (2, XMLTYPE('<?xml version="1.0" encoding="UTF-8"?>
<universitate>
  <fakultate nosaukums="Matematikas fakultate" fakultates_id="1">
    <studiju_programma nosaukums="Matematika un datu zinates" studiju_id="1">
      <studiju_kurss nosaukums="Statistika" kursa_id="2">
        <modulis nosaukums="Varbutiba" modula_id="3">
          <temats nosaukums="Varbutibu sadalijumi" temata_id="5">
            <apraksts>Matematiskie sadalijumi</apraksts>
            <kreditpunkti>2</kreditpunkti>
            <stundu_skaits>16</stundu_skaits>
          </temats>
        </modulis>
      </studiju_kurss>
    </studiju_programma>
  </fakultate>
</universitate>'));

INSERT INTO university_json (id, json_data)
VALUES (2, '{
    "universitate": {
      "fakultate": [
        {
          "nosaukums": "Matematikas fakultate",
          "fakultates_id": 1,
          "studiju_programma": {
            "nosaukums": "Matematika un datu zinates",
            "studiju_id": 1,
            "studiju_kurss": [
              {
                "nosaukums": "Statistika",
                "kursa_id": 2,
                "modulis": [
                  {
                    "nosaukums": "Varbutiba",
                    "modula_id": 3,
                    "temats": [
                      {
                        "nosaukums": "Varbutibu sadalijumi",
                        "temata_id": 5,
                        "apraksts": "Matematiskie sadalijumi",
                        "kreditpunkti": 2,
                        "stundu_skaits": 16
                      }
                    ]
                  }
                ]
              }
            ]
          }
        }
      ]
    }
  }');