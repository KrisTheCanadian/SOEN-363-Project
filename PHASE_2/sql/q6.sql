-- Which band shows up the most often in Alternative Music Data ? --
-- Which of their songs appear in the Popular Dataset, include artist name, title, date and country--
SELECT DISTINCT Popular.artist, Popular.title, Popular.date, Popular.country
FROM
         (SELECT alt."Artist Name", count(alt."Artist Name")
         FROM alternative_music_data alt
         GROUP BY alt."Artist Name"
         ORDER BY count(alt."Artist Name") desc LIMIT 1) as alt, "PopularDataset" as Popular
Where TRIM(Popular.artist) = alt."Artist Name"
