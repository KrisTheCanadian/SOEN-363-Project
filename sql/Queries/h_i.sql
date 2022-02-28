CREATE VIEW high_ratings AS
SELECT DISTINCT actors.name, movies.rating
FROM actors, movies
WHERE movies.rating >= 4
AND movies.mid = actors.mid;

CREATE VIEW low_ratings AS
SELECT DISTINCT actors.name, movies.rating
FROM actors, movies
WHERE movies.rating < 4
AND movies.mid = actors.mid;

SELECT COUNT(high_ratings.name)
FROM high_ratings;

SELECT COUNT(low_ratings.name)
FROM low_ratings;