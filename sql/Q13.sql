WITH RECURSIVE chain AS (
    SELECT 
        AMKA AS start_AMKA,
        AMKA AS current_AMKA,
        rank,
        AMKA_supervisor,
        0 AS level
    FROM doctor

    UNION ALL

    SELECT 
        c.start_AMKA,
        d.AMKA,
        d.rank,
        d.AMKA_supervisor,
        c.level + 1
    FROM doctor d
    JOIN chain c
        ON d.AMKA = c.AMKA_supervisor
)
SELECT start_AMKA, rank, level, AMKA_supervisor
FROM chain
ORDER BY start_AMKA, level;
