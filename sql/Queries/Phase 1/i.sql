SELECT a.name
    FROM movies m, actors a
    WHERE a.mid = m.mid
    GROUP BY a.name
    ORDER BY max(m.year) - min(m.year) DESC
    LIMIT 1

