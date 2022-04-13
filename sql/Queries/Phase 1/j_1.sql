/*
 Create a view called co_actors, which returns the distinct names of actors who played in at least one movie with
 Annette Nicole. Print the number of rows in this view.

 */
CREATE VIEW co_actors AS
SELECT DISTINCT a.name
FROM movies m, actors a
WHERE m.mid in (SELECT m.mid
                FROM movies m , actors a
                WHERE a.name = 'Annette Nicole'
                and a.mid = m.mid)
    and m.mid = a. mid;
SELECT count(*) from co_actors
