CREATE OR REPLACE VIEW count_doctor_age_procedures AS
SELECT 
    d.AMKA AS AMKA, 
    h.age AS age, 
    count(mp.proc_number) AS count_medical_procedures
FROM doctor d 
INNER JOIN human h
ON d.AMKA = h.AMKA
LEFT JOIN medical_procedure mp
ON d.AMKA = mp.AMKA_performer
GROUP BY 
    d.AMKA, 
    h.age
HAVING age < 35;

SELECT 
    AMKA, 
    age, 
    count_medical_procedures 
FROM count_doctor_age_procedures
WHERE 
    count_medical_procedures = (
        SELECT MAX(count_medical_procedures)
        FROM count_doctor_age_procedures
);
