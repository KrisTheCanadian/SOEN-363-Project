-- What are all the playlists that those Led Zeppelin songs feature in? --
SELECT DISTINCT Rock."Playlist"
FROM rock_music_data Rock
WHERE "Artist Name" = 'Led Zeppelin';