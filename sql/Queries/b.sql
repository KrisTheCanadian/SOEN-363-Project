SELECT a.name
FROM movies m, actors a
WHERE m.title = 'The Dark Knight'
    and m.mid = a.mid
    ORDER BY name;