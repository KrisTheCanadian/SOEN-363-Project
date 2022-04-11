SELECT ca.name
FROM co_actors ca
WHERE ca.name not in (SELECT DISTINCT ne.name
        FROM non_existent ne)
    AND ca.name <> 'Annette Nicole'