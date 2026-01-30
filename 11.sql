
-- In 11.sql, write a SQL query to list the titles of the five highest rated movies (in order) that Chadwick Boseman starred in, starting with the highest rated.
-- Your query should output a table with a single column for the title of each movie.
-- You may assume that there is only one person in the database with the name Chadwick Boseman.


select movies.title
from people
join stars on stars.person_id = people.id 
join ratings on ratings.movie_id = stars.movie_id
join movies on movies.id = stars.movie_id
order by ratings.rating DESC Limit 5;

