/*
 Create a view called co_actors, which returns the distinct names of actors who played in at least one movie with
 Annette Nicole. Print the number of rows in this view.

 This might be super wrong!!
 */

CREATE VIEW co_actors AS
    SELECT DISTINCT a.name, count(*) as "number of movies with annette nicole"
    FROM actors a,  movies m
    WHERE a.mid = m.mid
      AND m.mid IN (SELECT DISTINCT movies.mid
      FROM movies, actors Annette
      WHERE Annette.name = 'Annette Nicole')
    group by a.name;
