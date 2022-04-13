-- What are some good club music (danceability  > 0.8) listed as pop which artists also make music categorized as blues?
-- Return the pop song and blues song with its respective artist.

SELECT DISTINCT "Track Name" as blues_song, art as Artist, track as Pop_song
FROM (SELECT d."Artist Name" as art, p."Track Name" as track
    FROM blues_music_data as d, pop_music_data as p
    WHERE d."Artist Name" = p."Artist Name"
    AND p.danceability > 0.8) as temp, blues_music_data as b
WHERE b."Artist Name" = art