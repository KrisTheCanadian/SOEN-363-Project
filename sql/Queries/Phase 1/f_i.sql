SELECT *
FROM movies m
WHERE m.num_ratings in (SELECT max(movies.num_ratings)
                        FROM movies)
