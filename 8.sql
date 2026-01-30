

--toy story id = 114709

--we want movies.title = 'Toy Story' and to return the movies.id
--matching stars.movie_id we want all person_id and to match it with people.id and list all people.name

SELECT people.name
FROM movies
JOIN stars ON movies.id = stars.movie_id
JOIN people ON stars.person_id = people.id
WHERE movies.title = 'Toy Story';





-- In 8.sql, write a SQL query to list the names of all people who starred in Toy Story.
-- Your query should output a table with a single column for the name of each person.
-- You may assume that there is only one movie in the database with the title Toy Story.





