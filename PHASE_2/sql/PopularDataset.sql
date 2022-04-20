create table "PopularDataset"
(
    id       integer not null
        constraint "database to calculate popularity_pk"
            primary key,
    country  text,
    date     text,
    position numeric,
    uri      text,
    track    text,
    title    text,
    artist   text
);
