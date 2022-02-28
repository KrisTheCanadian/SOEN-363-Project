SELECT DISTINCT g.title
FROM
    (SELECT *
         FROM movies,
              tags,
              tag_names
         WHERE tags.mid = movies.mid
           AND tags.tid = tag_names.tid
           AND tag_names.tag LIKE '%good%') as g,
    (SELECT *
         FROM movies, tags, tag_names
         WHERE tags.mid = movies.mid
           AND tags.tid = tag_names.tid
           AND tag_names.tag LIKE '%bad%') as b
WHERE g.title IN (b.title)
