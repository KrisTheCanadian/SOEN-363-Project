/* Considering that there is no output from this query, it must mean that there is no correlation between high
   number of ratings and high movie ratings as previously assumed. */

(SELECT *
FROM movies m
WHERE m.num_ratings in (SELECT max(movies.num_ratings)
                        FROM movies))
INTERSECT

(SELECT *
FROM movies m
WHERE m.rating in (SELECT min(movies.rating)
                        FROM movies))