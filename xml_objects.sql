-- XML

SELECT XMLELEMENT("universitate",
    XMLAGG(
        XMLELEMENT("fakultate",
            XMLFOREST(
                f.fakultates_id AS "fakultates_id",
                f.nosaukums AS "nosaukums"
            ),
            (SELECT XMLAGG(
                XMLELEMENT("studiju_programma",
                    XMLFOREST(
                        sp.studiju_id AS "studiju_id",
                        sp.nosaukums AS "nosaukums"
                    ),
                    (SELECT XMLAGG(
                        XMLELEMENT("studiju_kurss",
                            XMLFOREST(
                                sk.kursa_id AS "kursa_id",
                                sk.nosaukums AS "nosaukums"
                            ),
                            (SELECT XMLAGG(
                                XMLELEMENT("modulis",
                                    XMLFOREST(
                                        m.modula_id AS "modula_id",
                                        m.nosaukums AS "nosaukums"
                                    ),
                                    (SELECT XMLAGG(
                                        XMLELEMENT("temats",
                                            XMLFOREST(
                                                t.temata_id AS "temata_id",
                                                t.nosaukums AS "nosaukums",
                                                t.apraksts AS "apraksts",
                                                t.kreditpunkti AS "kreditpunkti",
                                                t.stundu_skaits AS "stundu_skaits"
                                            )
                                        )
                                    ) FROM temats t WHERE t.modula_id = m.modula_id)
                                )
                            ) FROM modulis m WHERE m.kursa_id = sk.kursa_id)
                        )
                    ) FROM studiju_kurss sk WHERE sk.studiju_id = sp.studiju_id)
                )
            ) FROM studiju_programma sp WHERE sp.fakultates_id = f.fakultates_id)
        )
    )
) AS xml_output
FROM fakultate f;


-- JSON

SELECT JSON_OBJECT(
    'universitate' VALUE (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'fakultates_id' VALUE f.fakultates_id,
                'nosaukums' VALUE f.nosaukums,
                'studiju_programmas' VALUE (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'studiju_id' VALUE sp.studiju_id,
                            'nosaukums' VALUE sp.nosaukums,
                            'studiju_kursi' VALUE (
                                SELECT JSON_ARRAYAGG(
                                    JSON_OBJECT(
                                        'kursa_id' VALUE sk.kursa_id,
                                        'nosaukums' VALUE sk.nosaukums,
                                        'moduli' VALUE (
                                            SELECT JSON_ARRAYAGG(
                                                JSON_OBJECT(
                                                    'modula_id' VALUE m.modula_id,
                                                    'nosaukums' VALUE m.nosaukums,
                                                    'temati' VALUE (
                                                        SELECT JSON_ARRAYAGG(
                                                            JSON_OBJECT(
                                                                'temata_id' VALUE t.temata_id,
                                                                'nosaukums' VALUE t.nosaukums,
                                                                'apraksts' VALUE t.apraksts,
                                                                'kreditpunkti' VALUE t.kreditpunkti,
                                                                'stundu_skaits' VALUE t.stundu_skaits
                                                            )
                                                        )
                                                        FROM temats t
                                                        WHERE t.modula_id = m.modula_id
                                                    )
                                                )
                                            )
                                            FROM modulis m
                                            WHERE m.kursa_id = sk.kursa_id
                                        )
                                    )
                                )
                                FROM studiju_kurss sk
                                WHERE sk.studiju_id = sp.studiju_id
                            )
                        )
                    )
                    FROM studiju_programma sp
                    WHERE sp.fakultates_id = f.fakultates_id
                )
            )
        )
        FROM fakultate f
    ) RETURNING CLOB
) AS json_output
FROM DUAL;