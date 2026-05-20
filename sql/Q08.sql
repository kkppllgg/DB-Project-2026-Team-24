SELECT s.AMKA 
FROM staff s
LEFT JOIN staff_shift sh
ON 
    s.AMKA = sh.AMKA
    AND sh.dep_name = 'Cardiology' 
    AND sh.date = '2026-01-01'
WHERE sh.AMKA IS NULL;
