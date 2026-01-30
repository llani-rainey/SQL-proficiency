
-- In 12.sql, write a SQL query to list the titles of all movies in which both Bradley Cooper and Jennifer Lawrence starred.
-- Your query should output a table with a single column for the title of each movie.
-- You may assume that there is only one person in the database with the name Bradley Cooper.
-- You may assume that there is only one person in the database with the name Jennifer Lawrence.


select movies.title
from people 
join stars on stars.person_id = people.id
join movies on movies.id = stars.movie_id
where people.name in ('Jennifer Lawrence', 'Bradley Cooper');



select movies.title
from people 
join stars on stars.person_id = people.id
join movies on movies.id = stars.movie_id
where people.name  = 'Jennifer Lawrence'

INTERSECT

select movies.title
from people 
join stars on stars.person_id = people.id
join movies on movies.id = stars.movie_id
where people.name  = 'Bradley Cooper';


SELECT title
FROM movies
JOIN stars AS s1 ON movies.id = s1.movie_id
JOIN people AS p1 ON s1.person_id = p1.id
JOIN stars AS s2 ON movies.id = s2.movie_id
JOIN people AS p2 ON s2.person_id = p2.id
WHERE p1.name = 'Bradley Cooper'
  AND p2.name = 'Jennifer Lawrence';


--subquery with in used

SELECT movies.title
FROM movies
JOIN stars ON movies.id = stars.movie_id
JOIN people ON stars.person_id = people.id
WHERE people.name = 'Bradley Cooper'
  AND movies.id IN (
    SELECT movies.id
    FROM movies
    JOIN stars ON movies.id = stars.movie_id
    JOIN people ON stars.person_id = people.id
    WHERE people.name = 'Jennifer Lawrence'
  );

-- my subquery with in used
  
select movies.title
from people 
join stars on stars.person_id = people.id
join movies on movies.id = stars.movie_id
where people.name  = 'Bradley Cooper'
    AND movies.id IN (
    SELECT movies.id
    FROM movies
    JOIN stars ON movies.id = stars.movie_id
    JOIN people ON stars.person_id = people.id
    WHERE people.name = 'Jennifer Lawrence'
  );


  --Join + group by approaach:

SELECT movies.title
FROM movies
JOIN stars ON movies.id = stars.movie_id
JOIN people ON stars.person_id = people.id
WHERE people.name IN ('Bradley Cooper', 'Jennifer Lawrence')
GROUP BY movies.title
HAVING COUNT(DISTINCT people.name) = 2;