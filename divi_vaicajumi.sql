-- XMLTable vaicajumi

-- 1. Vaicajums: Iegust informaciju par visiem studiju kursiem un to moduliem
SELECT k.kursa_nos,
       m.modula_nos,
       t.temata_nos,
       t.apraksts,
       t.krediti,
       t.stundas
FROM university_xml x,
     XMLTABLE(
        '/universitate/fakultate/studiju_programma/studiju_kurss'
        PASSING x.XML_DATA
        COLUMNS 
            kursa_nos VARCHAR2(100) PATH '@nosaukums',
            modulis XMLTYPE PATH 'modulis'
     ) k,
     XMLTABLE(
        'modulis'
        PASSING k.modulis
        COLUMNS 
            modula_nos VARCHAR2(100) PATH '@nosaukums',
            temati XMLTYPE PATH 'temats'
     ) m,
     XMLTABLE(
        'temats'
        PASSING m.temati
        COLUMNS 
            temata_nos VARCHAR2(100) PATH '@nosaukums',
            apraksts VARCHAR2(200) PATH 'apraksts',
            krediti NUMBER PATH 'kreditpunkti',
            stundas NUMBER PATH 'stundu_skaits'
     ) t;

-- 2. Vaicajums: Iegust kopsavilkumu par fakultati un tas programmam
SELECT f.fakultates_nos,
       p.programmas_nos,
       COUNT(t.temata_nos) as tematu_skaits,
       SUM(t.krediti) as kopejie_krediti
FROM university_xml x,
     XMLTABLE(
        '/universitate/fakultate'
        PASSING x.XML_DATA
        COLUMNS 
            fakultates_nos VARCHAR2(100) PATH '@nosaukums'
     ) f,
     XMLTABLE(
        '/universitate/fakultate/studiju_programma'
        PASSING x.XML_DATA
        COLUMNS 
            programmas_nos VARCHAR2(100) PATH '@nosaukums'
     ) p,
     XMLTABLE(
        '//temats'
        PASSING x.XML_DATA
        COLUMNS 
            temata_nos VARCHAR2(100) PATH '@nosaukums',
            krediti NUMBER PATH 'kreditpunkti'
     ) t
GROUP BY f.fakultates_nos, p.programmas_nos;


-- XMLQuery vaicajumi

-- 1. Vaicajums: Iegust visus studiju kursus ar to kreditpunktiem
SELECT XMLQuery(
    'for $k in /universitate/fakultate/studiju_programma/studiju_kurss
    return
    <kurss>
        <nosaukums>{$k/@nosaukums/string()}</nosaukums>
        <kopejie_kreditpunkti>{sum($k//kreditpunkti)}</kopejie_kreditpunkti>
    </kurss>'
    PASSING xml_data
    RETURNING CONTENT
) FROM university_xml;

-- 2. Vaicajums: Iegust visus tematus kuru stundu skaits ir lielaks par 16
SELECT XMLQuery(
    'for $topic in /universitate//temats
    where $topic/stundu_skaits > 16
    return
        <temats_info>
            {$topic/@nosaukums}
            <modulis>{$topic/../@nosaukums}</modulis>
            <stundu_skaits>{$topic/stundu_skaits}</stundu_skaits>
            <apraksts>{$topic/apraksts}</apraksts>
        </temats_info>'
    PASSING xml_data
    RETURNING CONTENT
) AS garie_temati
FROM university_xml
WHERE XMLExists(
    '/universitate//temats[stundu_skaits > 16]'
    PASSING xml_data
);


-- XMLCast vaicajumi

-- 1. Vaicajums: Izgust kopejo kriditpunktu summu no 'Datu bazes' kursa
SELECT 
    XMLCAST(
        XMLQuery(
            'sum(/universitate/fakultate/studiju_programma/studiju_kurss[@nosaukums="Datu bazes"]//kreditpunkti)'
            PASSING xml_data
            RETURNING CONTENT
        ) AS NUMBER
    ) AS kopejie_kp
FROM university_xml
WHERE XMLExists(
    '/universitate/fakultate/studiju_programma/studiju_kurss[@nosaukums="Datu bazes"]'
    PASSING xml_data
);

-- 2. Vaicajums: Ieg?st kop?jo kreditpunktu summu visiem tematiem
SELECT 
  XMLCast(XMLQuery('//studiju_kurss/@nosaukums' PASSING xml_data RETURNING CONTENT) AS VARCHAR2(100)) AS kurss,
  XMLCast(XMLQuery('sum(//temats/kreditpunkti)' PASSING xml_data RETURNING CONTENT) AS NUMBER) AS kopejie_kreditpunkti
FROM university_xml;