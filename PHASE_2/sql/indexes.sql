create unique index populardataset_id_uindex
    on "PopularDataset" (id);

create index populardataset_track_uindex
    on "PopularDataset" (track);

create index populardataset_artist_index
    on "PopularDataset" (artist);

create unique index "hiphop_music_data_artist name_track name_uindex"
    on hiphop_music_data ("Artist Name", "Track Name");
