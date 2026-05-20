SELECT 
    COALESCE(CAST(summary.RawYear AS CHAR), 'All Years') AS Year,
    COALESCE(summary.dep_name, 'All Departments') AS dep_name,
    COALESCE(summary.DRG_code, 'All DRGs') AS DRG_code,
    COALESCE(summary.provider_name, 'All Providers') AS provider_name,
    summary.Expected_Cost AS "Expected Cost",
    summary.Additional_Charge AS "Additional Charge",
    summary.Income AS Income
FROM (
    SELECT 
        YEAR(h.discharge_timestamp) AS RawYear, 
        h.dep_name,
        h.DRG_code,
        i.provider_name,
        SUM(d.cost) AS Expected_Cost,
        SUM(h.total_cost - d.cost) AS Additional_Charge,
        SUM(h.total_cost) AS Income
    FROM hospitalization h 
    JOIN patient_insurance i ON h.AMKA_patient = i.AMKA
    JOIN DRG d ON d.DRG_code = h.DRG_code
    GROUP BY YEAR(h.discharge_timestamp), h.dep_name, h.DRG_code, i.provider_name
    WITH ROLLUP
) AS summary;
