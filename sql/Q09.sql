WITH bounded_hospitalizations AS (
	SELECT
    	AMKA_patient,
    	DATEDIFF(
        	LEAST(discharge_timestamp, '2025-12-31 23:59:59'),
        	GREATEST(admission_timestamp, '2025-01-01 00:00:00')
    	) AS duration_days
	FROM hospitalization
	WHERE admission_timestamp <= '2025-12-31 23:59:59'
  	AND (discharge_timestamp >= '2025-01-01 00:00:00' OR discharge_timestamp IS NULL)
)
SELECT
	AMKA_patient,
	duration_days
FROM bounded_hospitalizations
WHERE duration_days > 15
	  AND duration_days IN (
  	SELECT duration_days
  	FROM bounded_hospitalizations
  	GROUP BY duration_days
  	HAVING COUNT(DISTINCT AMKA_patient) > 1
  )
ORDER BY duration_days DESC, AMKA_patient ASC;
