/* Considering that there is no output from this query, it must mean that the
   number of ratings and the ratings are not correlated as previously assumed.*/
(SELECT *
FROM movies m
WHERE m.num_ratings in (SELECT max(movies.num_ratings)
                        FROM movies))
INTERSECT
(SELECT *
FROM movies m
WHERE m.rating in (SELECT max(movies.rating)
                        FROM movies))
