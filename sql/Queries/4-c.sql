CREATE MATERIALIZED VIEW most_popular AS
SELECT a1.name, count( DISTINCT a2.name) as coactors
FROM actors a1, actors a2
WHERE a1.mid = a2.mid
AND a1.name <> a2.name
GROUP BY a1.name
ORDER BY coactors DESC;

SELECT mp.name, mp.coactors
FROM most_popular mp
WHERE  mp.coactors >= (SELECT max(mp.coactors)
        FROM most_popular mp)