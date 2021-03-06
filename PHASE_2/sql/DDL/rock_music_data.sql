create table rock_music_data (
    "Artist Name"    text,
    "Track Name"     text,
    "Popularity"     integer,
    "Genres"         text,
    "Playlist"       text,
    danceability     numeric,
    energy           numeric,
    key              integer,
    loudness         numeric,
    mode             integer,
    speechiness      numeric,
    acousticness     numeric,
    instrumentalness numeric,
    liveness         numeric,
    valence          numeric,
    tempo            numeric,
    id               text,
    uri              text,
    track_href       text,
    analysis_url     text,
    duration_ms      integer,
    time_signature   integer
);
