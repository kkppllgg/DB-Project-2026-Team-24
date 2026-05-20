EXPLAIN SELECT *
FROM
(
    SELECT 
        h.admission_timestamp,
        h.adm_code,
        h.disch_code,
        h.total_cost
    FROM hospitalization AS h
    WHERE h.AMKA_patient = 11015000070
) AS h
 NATURAL JOIN
(
    SELECT 
        r.admission_timestamp,
        (
            r.medical_care +
            r.nursing_care +
            r.cleanliness +
            r.food +
            r.overall_experience
        ) / 5 AS avg_rating
    FROM review AS r
    WHERE r.AMKA_patient = 11015000070
) AS r;


EXPLAIN SELECT * FROM ( 
    SELECT h.admission_timestamp, h.adm_code, h.disch_code, h.total_cost 
    FROM hospitalization AS h FORCE INDEX (PRIMARY) 
    WHERE h.AMKA_patient = 11015000070 
) AS h 
NATURAL JOIN ( 
    SELECT r.admission_timestamp, ( r.medical_care + r.nursing_care + r.cleanliness + r.food + r.overall_experience ) / 5 AS avg_rating 
    FROM review AS r FORCE INDEX (PRIMARY)
    WHERE r.AMKA_patient = 11015000070 
) AS r;
