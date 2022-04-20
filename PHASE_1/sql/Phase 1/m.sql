/*movie DUPLICATES and how many*/
CREATE VIEW duplicate_Titles AS
SELECT m.title, COUNT(m.title)
FROM movies m
GROUP BY m.title
HAVING COUNT(m.title)>1;

/* find duplicate MIDS*/
CREATE VIEW duplicated_mid AS
SELECT DISTINCT m2.title, m2.mid
FROM movies m1, movies m2
WHERE m1.title = m2.title
AND m1.year = m2.year
AND m1.num_ratings = m2.num_ratings
AND m1.rating = m2.rating
AND m1.mid < m2.mid;

/* Removal of all duplicate Movies */
CREATE VIEW no_dups AS
SELECT *
FROM movies m
WHERE m.mid NOT IN (SELECT dm.mid
        from duplicated_mid dm);

/*Genres DUPLICATES*/
SELECT dm.title, g.mid, g.genre
FROM genres g, duplicated_mid dm
WHERE g.mid IN (SELECT dm.mid
        from duplicated_mid dm)
AND g.mid = dm.mid;

/*tags DUPLICATES*/
SELECT dm.title, t.tid, t.mid
FROM tags t, duplicated_mid dm
WHERE t.mid IN (SELECT dm.mid
        from duplicated_mid dm)
AND t.mid = dm.mid;

/* Removal of all duplicate genres */
CREATE VIEW no_dups_genres AS
SELECT *
FROM genres g
WHERE g.mid NOT IN (SELECT dm.mid
        from duplicated_mid dm);

/* Removal of all duplicate tags */
CREATE VIEW no_dups_tags AS
SELECT *
FROM tags t
WHERE t.mid NOT IN (SELECT dm.mid
        from duplicated_mid dm);



/*tag_names... NO DUPLICATES*/
SELECT tn.tid, COUNT(tn.tag)
FROM tag_names tn
GROUP BY tn.tid
HAVING COUNT(tn.tag) > 1;


/*actor duplicates... NO DUPLICATES*/
SELECT a.name, a.mid, COUNT(a.cast_position)
FROM actors a
GROUP BY a.name, a.mid
HAVING COUNT(a.cast_position)>1;
