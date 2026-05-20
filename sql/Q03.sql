SELECT 
 AMKA_patient,
    SUM(total_cost)
FROM hospitalization
GROUP BY AMKA_patient, dep_name
HAVING COUNT(*) > 3
ORDER BY AMKA_patient, dep_name;