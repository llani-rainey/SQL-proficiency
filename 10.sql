
-- In 10.sql, write a SQL query to list the names of all people who have directed a movie that received a rating of at least 9.0.
-- Your query should output a table with a single column for the name of each person.
-- If a person directed more than one movie that received a rating of at least 9.0, they should only appear in your results once.

select distinct name
from people
join directors on directors.person_id = people.id
join ratings on ratings.movie_id = directors.movie_id 
where ratings.rating >= 9.0; 

--or 

select distinct people.name
from people
join directors on directors.person_id = people.id
join movies on movies.id = directors.movie_id
join ratings on ratings.movie_id = movies.id
where ratings.rating >= 9.0;

== or 



DIRECOTRS :     directors.person_id
RATINGS:        directors.movie_id = ratings.

ratings.rating >= 9.0

