--How many pop songs released in 2020 that are in the top 20 have a tempo greater than 120?

SELECT COUNT(Distinct "Track Name")
FROM pop_music_data as p, "PopularDataset" as d
WHERE TRIM(d.title) = p."Track Name"
AND d.date LIKE '%2020%'
AND d.position < 21
AND p.tempo > 120