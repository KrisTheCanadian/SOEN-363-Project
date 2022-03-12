-- Important Properties for Movies: actors, tags, genres, year and rating
-- similarity between two movies: sim(X,Y)
-- fraction of common attributes: actors + tags + genres + age gap + rating gap / 5
-- fraction is X / Y
-- rating gap is the normalized difference between the ratings of X and Y
-- each property is given a weight value of 1

-- selecting the target movie ’Mr. & Mrs. Smith’ and returning the movie id
CREATE MATERIALIZED VIEW target_id (mid) AS
SELECT MIN(movies.mid)
FROM movies
WHERE movies.title = 'Mr. & Mrs. Smith';


-- return movie title
CREATE MATERIALIZED VIEW target_title (title) AS
SELECT MIN(movies.mid)
FROM movies
WHERE movies.mid = (SELECT mid FROM target_id);

-- returning target movie actor names
CREATE MATERIALIZED VIEW target_actor_names (name) AS
SELECT DISTINCT(actors.name)
FROM actors
WHERE actors.mid = (SELECT mid FROM target_id);

-- returning target movie tag names
CREATE MATERIALIZED VIEW target_tags (tag) AS
SELECT DISTINCT(tag)
FROM tag_names, tags
WHERE tags.mid = (SELECT mid FROM target_id)
    AND tags.tid = tag_names.tid;

-- returning target movie genres
CREATE MATERIALIZED VIEW target_genres (genre) AS
SELECT DISTINCT (genre)
FROM genres
WHERE genres.mid = (SELECT mid FROM target_id);

-- returning target movie years
CREATE MATERIALIZED VIEW target_age (age) AS
SELECT year
FROM movies
WHERE mid = (SELECT mid FROM target_id);

-- returning target movie rating
CREATE MATERIALIZED VIEW target_rating (rating) AS
SELECT rating
FROM movies
WHERE mid = (SELECT mid FROM target_id);

-- calculating the fraction of common actors with all movies
CREATE MATERIALIZED VIEW common_actors(mid, result) AS
SELECT actors.mid, CAST((COUNT(*) * 1.0 / (SELECT COUNT(*) FROM target_actor_names)) AS DECIMAL (10, 3))
FROM actors
WHERE actors.mid <> (SELECT mid FROM target_id)
    AND actors.name IN (SELECT name FROM target_actor_names)
GROUP BY actors.mid;

-- calculating the fraction of common tags with all the movies
CREATE MATERIALIZED VIEW common_tags(mid, result) AS
SELECT tags.mid, CAST ((COUNT ( DISTINCT tag_names.tag) * 1.0 / (SELECT COUNT(*) FROM target_tags)) AS DECIMAL)
FROM tags, tag_names
WHERE tags.tid = tag_names.tid
    AND tags.mid <> (SELECT mid FROM target_id)
    AND tag_names.tag IN (SELECT target_tags.tag FROM target_tags)
GROUP BY tags.mid;

-- calculating the fraction of common genres with all the movies

CREATE MATERIALIZED VIEW common_genres(mid, result) AS
SELECT genres.mid, CAST ((COUNT(DISTINCT genres) * 1.0 / (SELECT COUNT(*) FROM target_genres)) AS DECIMAL(10, 3))
FROM genres
WHERE genres.mid <> (SELECT mid FROM target_id)
    AND genres.genre IN (SELECT genre FROM target_genres)
group by genres.mid;

-- return max age gap from target movie and another
CREATE MATERIALIZED VIEW max_age_gap (result) AS
SELECT MAX(ABS(year - (SELECT MAX(target_age.age) FROM target_age)))
FROM movies
WHERE movies.mid <> (SELECT mid FROM target_id);


-- calculating the age gap with all the movies
CREATE MATERIALIZED VIEW age_gap (mid, result) AS
SELECT mid, CAST(((SELECT result FROM max_age_gap) - ABS((SELECT MAX(target_age.age) FROM target_age) - year * 1.0))
                     / (SELECT result FROM max_age_gap) AS DECIMAL(10, 3))
FROM movies
WHERE movies.mid <> (SELECT mid FROM target_id);

-- calculating the rating gap with all the movies
CREATE MATERIALIZED VIEW rating_gap(mid, result) AS
SELECT mid, CAST(ABS((SELECT MAX(target_rating.rating) FROM target_rating) - ABS((SELECT MAX(target_rating.rating) FROM target_rating) - rating * 1.0))
                     / (SELECT MAX(target_rating.rating) FROM target_rating) AS DECIMAL(10, 3))
FROM movies
WHERE mid <> (SELECT mid FROM target_id);

-- total similar movies
CREATE MATERIALIZED VIEW similar_movies (mid, similarity) AS
SELECT age_gap.mid,
       CAST( (
           (COALESCE(age_gap.result, 0)) +
           (COALESCE(rg.result, 0)) +
           (COALESCE(cg.result, 0)) +
           (COALESCE(ca.result, 0)) +
           (COALESCE(ct.result, 0)) ) / 5 AS DECIMAL(10, 3)
        ) AS similarity
FROM age_gap
    FULL OUTER JOIN rating_gap rg ON age_gap.mid = rg.mid
    FULL OUTER JOIN common_genres cg ON age_gap.mid = cg.mid
    FULL OUTER JOIN common_actors ca on age_gap.mid = ca.mid
    FULL OUTER JOIN common_tags ct on age_gap.mid = ct.mid;

-- top 10 & similarity % // Note the database has another unique Mr. & Mrs. Smith (which should probably not be in there)
-- Assuming the database is clean, this implementation should work.
SELECT movies.title, CONCAT(similar_movies.similarity * 100, ' %') AS similarity_rating, movies.rating as movie_rating
FROM similar_movies, movies
WHERE similar_movies.mid = movies.mid
ORDER BY similar_movies.similarity DESC
LIMIT 10;