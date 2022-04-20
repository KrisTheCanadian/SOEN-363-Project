
CREATE MATERIALIZED VIEW target_id_mat (mid) AS
SELECT MAX(movies.mid)
FROM movies
WHERE movies.title = 'Mr. & Mrs. Smith';

CREATE MATERIALIZED VIEW target_actor_names_mat (name) AS
SELECT DISTINCT(actors.name)
FROM actors
WHERE actors.mid = (SELECT mid FROM target_id);

CREATE MATERIALIZED VIEW target_tags_mat (tag) AS
SELECT DISTINCT(tag)
FROM tag_names, tags
WHERE tags.mid = (SELECT mid FROM target_id)
    AND tags.tid = tag_names.tid;

CREATE MATERIALIZED VIEW target_genres_mat (genre) AS
SELECT DISTINCT (genre)
FROM genres
WHERE genres.mid = (SELECT mid FROM target_id);

CREATE MATERIALIZED VIEW target_age_mat (age) AS
SELECT year
FROM movies
WHERE mid = (SELECT mid FROM target_id);

CREATE MATERIALIZED VIEW target_rating_mat (rating) AS
SELECT rating
FROM movies
WHERE mid = (SELECT mid FROM target_id);

CREATE MATERIALIZED VIEW common_actors_mat(mid, result) AS
SELECT actors.mid, (COUNT(*) * 1.0 / (SELECT COUNT(*) FROM target_actor_names))
FROM actors
WHERE actors.mid <> (SELECT mid FROM target_id)
    AND actors.name IN (SELECT name FROM target_actor_names)
GROUP BY actors.mid;

CREATE MATERIALIZED VIEW common_tags_mat(mid, result) AS
SELECT tags.mid, COUNT(DISTINCT tag_names.tag) * 1.0 / (SELECT COUNT(*) FROM target_tags)
FROM tags, tag_names
WHERE tags.tid = tag_names.tid
    AND tags.mid <> (SELECT mid FROM target_id)
    AND tag_names.tag IN (SELECT target_tags.tag FROM target_tags)
GROUP BY tags.mid;

CREATE MATERIALIZED VIEW common_genres_mat(mid, result) AS
SELECT genres.mid, COUNT(DISTINCT genres) * 1.0 / (SELECT COUNT(*) FROM target_genres)
FROM genres
WHERE genres.mid <> (SELECT mid FROM target_id)
    AND genres.genre IN (SELECT genre FROM target_genres)
group by genres.mid;

CREATE MATERIALIZED VIEW max_age_gap_mat (result) AS
SELECT MAX(ABS(year - (SELECT target_age.age FROM target_age)))
FROM movies m1
WHERE m1.mid <> (SELECT mid FROM target_id);

CREATE MATERIALIZED VIEW age_gap_mat (mid, result) AS
SELECT mid, 1 - COALESCE(((ABS((SELECT target_age.age FROM target_age) - year * 1.0))/(SELECT result FROM max_age_gap)),1)
FROM movies
WHERE movies.mid <> (SELECT mid FROM target_id);

CREATE MATERIALIZED VIEW rating_gap_mat(mid, result) AS
SELECT mid, 1 - COALESCE(((ABS((SELECT target_rating.rating FROM target_rating) - rating * 1.0) - 0.0)/(SELECT target_rating.rating FROM target_rating)),1)
FROM movies
WHERE mid <> (SELECT mid FROM target_id);

CREATE MATERIALIZED VIEW similar_movies_mat (mid, similarity) AS
SELECT age_gap.mid, (((COALESCE(age_gap.result, 0)) +(COALESCE(rg.result, 0)) +(COALESCE(cg.result, 0)) + (COALESCE(ca.result, 0)) + (COALESCE(ct.result, 0)) ) / 5) AS similarity
FROM age_gap
    FULL OUTER JOIN rating_gap rg ON age_gap.mid = rg.mid
    FULL OUTER JOIN common_genres cg ON age_gap.mid = cg.mid
    FULL OUTER JOIN common_actors ca on age_gap.mid = ca.mid
    FULL OUTER JOIN common_tags ct on age_gap.mid = ct.mid;

-- Note the database has another unique Mr. & Mrs. Smith (which should probably not be in there)
-- Assuming the database is clean, this implementation should work.
SELECT movies.title, movies.rating, CONCAT(similar_movies.similarity * 100, ' %') AS similarity_percentage, movies.year
FROM similar_movies, movies
WHERE similar_movies.mid = movies.mid
ORDER BY similar_movies.similarity DESC
limit 10