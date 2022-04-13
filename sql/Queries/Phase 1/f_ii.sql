SELECT *
FROM movies m
WHERE m.rating in (SELECT max(movies.rating)
                        FROM movies)
