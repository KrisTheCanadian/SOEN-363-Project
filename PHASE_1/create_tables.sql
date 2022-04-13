CREATE TABLE movies (
    mid integer,
    title varchar,
    year integer,
    rating real,
    num_ratings integer,
    PRIMARY KEY (mid)
);

CREATE TABLE actors (
    mid integer,
    name varchar,
    cast_position integer,
    FOREIGN KEY (mid) REFERENCES movies(mid),
    PRIMARY KEY (name, mid)
);

CREATE TABLE genres (
    mid integer,
    genre varchar,
    FOREIGN KEY (mid) REFERENCES movies(mid),
    PRIMARY KEY (genre, mid)
);

CREATE TABLE tag_names (
    tid integer,
    tag varchar,
    PRIMARY KEY (tid)
);

CREATE TABLE tags (
    mid integer,
    tid integer,
    FOREIGN KEY (mid) REFERENCES movies(mid),
    FOREIGN KEY (tid) REFERENCES tag_names(tid),
    PRIMARY KEY (mid, tid)
);
