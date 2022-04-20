-- Which Artists appear in both the indie and alternative music data starting by the letter S--
SELECT Distinct alt."Artist Name"
FROM indie_alt_music_data indie, alternative_music_data alt
WHERE indie."Artist Name" = alt."Artist Name"
    and alt."Artist Name" Like 'S%'