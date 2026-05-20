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
     USING (AMKA_patient,admission_timestamp));
