WITH doctors_rank AS (
        	SELECT
        	        	d.AMKA,
                    	count(mp.proc_number) AS count_procedures,
                    	MAX(count(mp.proc_number)) OVER () AS max_procedures
        	FROM doctor d
        	LEFT JOIN medical_procedure mp
        	ON
d.AMKA = mp.AMKA_performer
AND mp.proc_date >= '2026-01-01'
AND mp.proc_date <= CURRENT_DATE
        	GROUP BY d.AMKA
)
SELECT
        	AMKA,
        	count_procedures
FROM doctors_rank
WHERE count_procedures <= max_procedures - 5;
 
