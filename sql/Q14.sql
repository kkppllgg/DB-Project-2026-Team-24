WITH codes_per_year AS (
SELECT 
LEFT(adm_code, 1) AS ICD_category, 
YEAR(admission_timestamp) AS year, 
count(AMKA_patient) AS count 
FROM hospitalization
GROUP BY 
LEFT(adm_code, 1), 
YEAR(admission_timestamp)
HAVING count >= 5
)
SELECT DISTINCT cpy1.ICD_category
-- για quality check
-- χωρίς το DISTINCT cpy1.ICD_category, 
-- cpy1.year AS year1, 
-- cpy2.year AS year2, 
-- cpy1.count as count
FROM codes_per_year cpy1
INNER JOIN codes_per_year cpy2
ON cpy1.ICD_category = cpy2.ICD_category
AND cpy1.count = cpy2.count
AND cpy2.year = cpy1.year + 1;
