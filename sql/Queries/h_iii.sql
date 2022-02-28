SELECT high_ratings.name, COUNT(movies.title) as movies
FROM high_ratings, movies, actors
WHERE high_ratings.name = actors.name
AND actors.mid = movies.mid
GROUP BY high_ratings.name
ORDER BY movies desc
LIMIT 10