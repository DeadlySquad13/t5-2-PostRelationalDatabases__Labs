WITH RECURSIVE r AS (
    -- стартовая часть рекурсии
    SELECT
        1 as i,
        1 AS factorial

    UNION

    -- рекурсивная часть
    SELECT
        i+1 AS i,
        factorial * (i+1) as factorial
    FROM r
    WHERE i < 10
)
SELECT * FROM r;
