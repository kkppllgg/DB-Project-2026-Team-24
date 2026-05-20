SELECT
	s1.substance_name AS substance_1,
	s2.substance_name AS substance_2,
	COUNT(*) AS frequency
FROM prescription p1
JOIN has_substance s1
	ON p1.medicine_name = s1.medicine_name
JOIN prescription p2
	ON p1.AMKA_patient = p2.AMKA_patient
	AND p1.admission_timestamp = p2.admission_timestamp
JOIN has_substance s2
	ON p2.medicine_name = s2.medicine_name
WHERE s1.substance_name < s2.substance_name
GROUP BY s1.substance_name, s2.substance_name
ORDER BY frequency DESC
LIMIT 3;
