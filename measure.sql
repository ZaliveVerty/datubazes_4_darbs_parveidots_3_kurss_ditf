SET TIMING ON;

DECLARE
    v_json_result CLOB;
BEGIN
    FOR i IN 1..5000 LOOP
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
        ) INTO v_json_result
        FROM DUAL;
    END LOOP;
END;
/

SET TIMING OFF;