-- What are all Led Zeppelin song names in rock_Music_data, --
-- and on which days do they end up on the popularDataSet in 2018 --
SELECT popular.title, popular.date, popular.country
FROM "PopularDataset" as popular
WHERE TRIM(popular.title) in (
    SELECT DISTINCT Rock."Track Name"
    FROM rock_music_data Rock
    WHERE "Artist Name" = 'Led Zeppelin')
and popular.date LIKE '%2018%'
