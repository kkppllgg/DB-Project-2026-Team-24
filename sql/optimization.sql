EXPLAIN 
SELECT AVG(r.medical_care) as avg_medical_care, AVG(r.overall_experience) AS avg_overall_experience
FROM ((
    SELECT DISTINCT AMKA_patient,admission_timestamp      FROM prescription
    WHERE AMKA_doctor = 11015032143) AS d
JOIN review AS r
    USING (AMKA_patient,admission_timestamp) );

EXPLAIN 
SELECT AVG(r.medical_care) as avg_medical_care, AVG(r.overall_experience) AS avg_overall_experience
FROM ((
    SELECT DISTINCT AMKA_patient,admission_timestamp      FROM prescription FORCE INDEX (PRIMARY)
    WHERE AMKA_doctor = 11015032143) AS d 
JOIN review AS r FORCE INDEX (PRIMARY)
    USING (AMKA_patient,admission_timestamp) );


CREATE INDEX misleading_index1 ON prescription (frequency);
CREATE INDEX misleading_index2 ON review (nursing_care);
SHOW INDEX FROM prescription;
SHOW INDEX FROM review;

EXPLAIN
SELECT AVG(r.medical_care) as avg_medical_care, AVG(r.overall_experience) AS avg_overall_experience
FROM ((
    SELECT DISTINCT AMKA_patient,admission_timestamp      FROM prescription FORCE INDEX (misleading_index1)
    WHERE AMKA_doctor = 11015032143) AS d 
JOIN review AS r FORCE INDEX (misleading_index2)
    USING (AMKA_patient,admission_timestamp) );
DROP INDEX misleading_index1 ON prescription;
DROP INDEX misleading_index2 ON review;




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

CREATE INDEX misleading_index1 ON hospitalization (adm_code);
CREATE INDEX misleading_index2 ON review (nursing_care);


EXPLAIN SELECT * FROM ( 
    SELECT h.admission_timestamp, h.adm_code, h.disch_code, h.total_cost 
    FROM hospitalization AS h FORCE INDEX (misleading_index1) 
    WHERE h.AMKA_patient = 11015000070 
) AS h 
NATURAL JOIN ( 
    SELECT r.admission_timestamp, ( r.medical_care + r.nursing_care + r.cleanliness + r.food + r.overall_experience ) / 5 AS avg_rating 
    FROM review AS r FORCE INDEX (misleading_index2)
    WHERE r.AMKA_patient = 11015000070 
) AS r;

DROP INDEX misleading_index1 ON hospitalization;
DROP INDEX misleading_index2 ON review;

