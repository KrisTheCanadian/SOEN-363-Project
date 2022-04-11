SELECT DISTINCT temp.year, title, temp.rating
FROM movies, (SELECT min(rating) as rating, year
        FROM movies
        WHERE year between 2005 and 2011
        GROUP BY year

    UNION

    SELECT max(rating) as rating, year
        FROM movies
        WHERE year between 2005 and 2011
        GROUP BY year) as temp
WHERE movies.rating = temp.rating
AND movies.year = temp.year
ORDER BY temp.year, movies.title