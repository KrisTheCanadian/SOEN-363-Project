SELECT playlist, "Track Name", duration_ms
FROM (SELECT COUNT(p."Playlist") as count, p."Playlist" as playlist
    FROM alternative_music_data as p
    GROUP BY p."Playlist"
    ORDER BY count DESC
    LIMIT 1) as temp, alternative_music_data as d
WHERE d.duration_ms > 300000
AND d."Playlist" = playlist
ORDER BY d.duration_ms;