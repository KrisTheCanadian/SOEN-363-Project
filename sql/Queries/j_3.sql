SELECT *
FROM all_combinations ac, co_actors cs, movies m
WHERE m.mid in (SELECT m.mid
                FROM co_actors cs, movies m)