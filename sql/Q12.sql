SELECT 
    ss.dep_name,
    ss.date,
    ss.shift_type,
    s.staff_type,
    CASE
        WHEN s.staff_type = 'doctor' THEN d.specialization
        WHEN s.staff_type = 'nurse' THEN n.rank
        WHEN s.staff_type = 'administrator' THEN a.duty
    END AS subclass_detail,
    COUNT(ss.AMKA) AS required_staff_count
FROM
    staff_shift ss 
LEFT JOIN 
    staff s ON ss.AMKA = s.AMKA 
LEFT JOIN 
    doctor d ON s.staff_type = 'doctor' AND ss.AMKA = d.AMKA
LEFT JOIN 
    nurse n ON s.staff_type = 'nurse' AND ss.AMKA = n.AMKA
LEFT JOIN 
    administrator a ON s.staff_type = 'administrator' AND ss.AMKA = a.AMKA
WHERE 
    ss.date BETWEEN '2026-01-01' AND '2026-01-08' -- Replace with your desired week
GROUP BY 
    ss.dep_name,
    ss.date,
    ss.shift_type,
    s.staff_type,
    CASE
        WHEN s.staff_type = 'doctor' THEN d.specialization
        WHEN s.staff_type = 'nurse' THEN n.rank
        WHEN s.staff_type = 'administrator' THEN a.duty
    END
ORDER BY 
    ss.dep_name, 
    ss.date, 
    ss.shift_type;

