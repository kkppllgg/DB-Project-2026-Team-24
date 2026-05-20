SELECT 
    d.AMKA AS AMKA, 
    d.specialization AS specialization, 
    CASE 
        WHEN EXISTS (
            SELECT AMKA from staff_shift sh
            WHERE 
                d.AMKA = sh.AMKA
                AND sh.date >= '2026-01-01'
                AND sh.date <= CURRENT_DATE
            ) THEN 'yes' ELSE 'no'
    END AS had_night_shift_this_year, 
    count(mp.proc_number) AS count_medical_procedures
FROM doctor d
LEFT JOIN medical_procedure mp
ON d.AMKA = mp.AMKA_performer
WHERE d.specialization = 'Καρδιολογία'
GROUP BY 
    d.AMKA,
    d.specialization;
