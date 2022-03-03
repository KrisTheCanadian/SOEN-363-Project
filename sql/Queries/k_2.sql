SELECT a.name, m.mid
FROM actors a, movies m
WHERE a.name in (SELECT DISTINCT a.name
FROM actors a)
    and a.mid = m.mid