-- Which songs have the most genres (limit to 10 results)?

SELECT "Track Name", len as num_genres
FROM (SELECT "Track Name", array_length(regexp_split_to_array("Genres", ','),1) as len
            FROM indie_alt_music_data

            UNION

            SELECT "Track Name", array_length(regexp_split_to_array("Genres", ','),1) as len
            FROM alternative_music_data

            UNION

            SELECT "Track Name", array_length(regexp_split_to_array("Genres", ','),1) as len
            FROM blues_music_data

            UNION

            SELECT "Track Name", array_length(regexp_split_to_array("Genres", ','),1) as len
            FROM hiphop_music_data

            UNION

            SELECT "Track Name", array_length(regexp_split_to_array("Genres", ','),1) as len
            FROM metal_music_data

            UNION

            SELECT "Track Name", array_length(regexp_split_to_array("Genres", ','),1) as len
            FROM pop_music_data

            UNION

            SELECT "Track Name", array_length(regexp_split_to_array("Genres", ','),1) as len
            FROM rock_music_data) as temp
ORDER BY len DESC
LIMIT 10