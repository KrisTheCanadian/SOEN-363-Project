-- What is the largest popularity gap in rock_Music (lowest popularity, highest popularity)? --
SELECT Top."Popularity" - Bottom."Popularity" as PopularityGap
FROM   (Select rock."Popularity"
        FROM rock_music_data as rock
        ORDER By rock."Popularity" desc LIMIT 1) as Top,
        (Select rock."Popularity"
        FROM rock_music_data as rock
        ORDER By rock."Popularity" LIMIT 1) as bottom
