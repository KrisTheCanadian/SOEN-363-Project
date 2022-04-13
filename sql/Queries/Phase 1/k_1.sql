SELECT a2.name, count(DISTINCT a.name)
FROM actors a, movies m, actors a2
WHERE m.mid in (SELECT m.mid
                FROM actors a, movies m
                WHERE a.name = 'Tom Cruise'
                AND a.mid = m.mid)
and a.mid = m.mid
and a.name <> 'Tom Cruise'
and a2.name = 'Tom Cruise'
group by a2.name
