SELECT 
    s.substance_name AS substance, 
    count(DISTINCT ha.AMKA_patient) AS count_allergic_patients, 
    count(DISTINCT hs.medicine_name) AS count_medicine
FROM substance s
LEFT JOIN has_allergy ha
ON s.substance_name = ha.substance_name
LEFT JOIN has_substance hs
ON s.substance_name = hs.substance_name
GROUP BY s.substance_name
ORDER BY count_allergic_patients DESC;

