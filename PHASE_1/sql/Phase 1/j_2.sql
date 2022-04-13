CREATE VIEW all_combinations AS
SELECT c.name, m.mid
FROM movies m, co_actors c
WHERE m.mid in (SELECT m.mid
                FROM movies m , actors a
                WHERE a.name = 'Annette Nicole'
                and a.mid = m.mid);
SELECT count(*) from all_combinations