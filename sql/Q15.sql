SELECT * 
FROM
(
    SELECT 
        urgency, 
        COUNT(*) AS distribution,
        AVG(TIMESTAMPDIFF(MINUTE, admission_timestamp, triage_discharge)) AS 'mean_wait',
AVG(state = 'inactive' )*100 AS 'hospitalization_percentage' 
    FROM triage
    GROUP BY urgency
) AS t1
JOIN 
(
    SELECT 
       t.urgency,
        h.dep_name,
        COUNT(*) AS dep_distr
    FROM (
        SELECT * 
        FROM triage
        WHERE state = 'inactive'
    ) AS t
    JOIN hospitalization AS h 
        ON t.AMKA_patient = h.AMKA_patient 
        AND t.admission_timestamp = h.admission_timestamp
    GROUP BY t.urgency, h.dep_name
) AS t2
ON t1.urgency = t2.urgency; 
