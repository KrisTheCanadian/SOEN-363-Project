CREATE VIEW non_existent AS
SELECT ac.name, ac.mid
FROM all_combinations ac
EXCEPT(SELECT DISTINCT a.name, m.mid
        FROM movies m, actors a
                WHERE m.mid in (SELECT m.mid
                                FROM movies m , actors a
                                WHERE a.name = 'Annette Nicole'
                                and a.mid = m.mid)
                and m.mid = a. mid);
SELECT count(*) FROM non_existent
