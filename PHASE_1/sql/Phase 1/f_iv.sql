/* Print all information (mid, title, year, num ratings, rating) for the movie(s) with the lowest rating (include tuples
  that tie), sorted by the ascending order of movie id. */

(SELECT m.mid, m.title, m.year, m.num_ratings, m.rating
FROM movies m
WHERE m.rating in (SELECT min(rating) FROM movies) ORDER BY m.mid)