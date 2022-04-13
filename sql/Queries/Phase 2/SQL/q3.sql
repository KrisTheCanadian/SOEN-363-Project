-- What were the most popular songs (songs listed in the top 3) of the month of January of 2019 in Canada?
-- Order by popularity and limit output to 10.

SELECT DISTINCT track, position
FROM "PopularDataset" as p
WHERE p.country = 'Canada'
AND p.date LIKE '%01/2019%'
AND p.position < 4
ORDER BY position
LIMIT 10