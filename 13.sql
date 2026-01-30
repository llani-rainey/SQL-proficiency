


-- In 13.sql, write a SQL query to list the names of all people who starred in a movie in which Kevin Bacon also starred.
-- Your query should output a table with a single column for the name of each person.
-- There may be multiple people named Kevin Bacon in the database. Be sure to only select the Kevin Bacon born in 1958.
-- Kevin Bacon himself should not be included in the resulting list.


select distinct people.name
from people
join stars on stars.person_id = people.id 
join movies on movies.id = stars.movie_id

where people.name = 'Kevin Bacon' AND people.birth = '1958'


-- 1. Subquery with IN (most readable and widely used)
SELECT DISTINCT people.name
FROM people
JOIN stars ON people.id = stars.person_id
WHERE stars.movie_id IN (
    SELECT stars.movie_id
    FROM stars
    JOIN people ON stars.person_id = people.id
    WHERE people.name = 'Bob' AND people.birth = 1990
)
AND NOT (people.name = 'Bob' AND people.birth = 1990);

--2 INTERSECT (elegant, concise)
SELECT name
FROM people
JOIN stars ON people.id = stars.person_id
WHERE NOT (people.name = 'Bob' AND people.birth = 1990)
INTERSECT
SELECT name
FROM people
JOIN stars ON people.id = stars.person_id
WHERE stars.movie_id IN (
    SELECT stars.movie_id
    FROM stars
    JOIN people ON stars.person_id = people.id
    WHERE people.name = 'Bob' AND people.birth = 1990
);



-- 3. EXISTS with correlated subquery
SELECT DISTINCT people.name
FROM people
JOIN stars AS s1 ON people.id = s1.person_id
WHERE EXISTS (
    SELECT 1
    FROM stars AS s2
    JOIN people AS p2 ON s2.person_id = p2.id
    WHERE s2.movie_id = s1.movie_id
    AND p2.name = 'Bob' AND p2.birth = 1990
)
AND NOT (people.name = 'Bob' AND people.birth = 1990);


--4. self-join
SELECT DISTINCT p1.name
FROM stars s1
JOIN people p1 ON s1.person_id = p1.id
JOIN stars s2 ON s1.movie_id = s2.movie_id
JOIN people p2 ON s2.person_id = p2.id
WHERE p2.name = 'Bob' AND p2.birth = 1990
AND NOT (p1.name = 'Bob' AND p1.birth = 1990);



--people (twice) → stars (twice) ← movies
-- we need stars twice, once for Bob and once for all the co-stars
--movies to connect those two records [the movie id is held within stars so no need to pull in actual movies table]
--people twie to get Bob's ID and the co-stars' names

--joining stars to irself on movie_id finds pairs of people in the same movie
--people ussed twice to get names: one for Bob, one for co-stars
--stars table connect peopel to movies



--let p1 represent all the costars,  and let p2 represent kevin bacon
--let s1 represent a list of all people who acted in movies, these are possible co-stars which we'll call p1 soon
-- now call them p1, linking each persons ID to the movies's record of them working on it [held within stars using stars.movie_id]
--Find other people (s2) who were in the same movie IDs using second stars variable [i.e match up actors from the same film]
--For each person in s2 (from the previous line), find their name and birth info from the people table, and call them p2.”
--filter down to all the people in p2 who match up Kevin Bacon born in 1958 but then
--finally exclude Kevin bacon himself who is in the p1 set (and p2 set)

select distinct p1.name
from stars s1
join people p1 on p1.id = s1.person_id
join stars s2 on s1.movie_id = s2.movie_id
join people p2 on p2.id = s2.person_id
where p2.name = 'Kevin Bacon' AND p2.birth = 1958
AND NOT (p1.name = 'Kevin Bacon' AND p1.birth = 1958);

--Write a SQL query to list the names of pairs of actors who have appeared in more than one movie together.

--we want 3 columns, actor1, actor2, n_of_movies_together
--we want to match actor1 and actor2 on stars.movie_id
--we need stars twice to do this (self join on stars), we need to count the number of stars.movie_id everytime there's a match and only show if 2 or more


SELECT p1.name AS actor1, p2.name AS actor2, COUNT(*) AS number_of_movies_together
FROM stars s1
JOIN stars s2 ON s2.movie_id = s1.movie_id
JOIN people p1 ON p1.id = s1.person_id
JOIN people p2 ON p2.id = s2.person_id
WHERE s1.person_id < s2.person_id
GROUP BY p1.name, p2.name
HAVING COUNT(*) >= 2 LIMIT 5;

/* shift option a to multi line comment */
--Find all pairs of actors who have appeared together in exactly one movie.
/* 	•	Output columns:
	•	actor1 (name)
	•	actor2 (name)
	•	movie_title (title of the single movie they acted in together)
	•	Make sure each pair appears only once (i.e., (A, B) and not (B, A) */



SELECT p1.name AS actor1, p2.name AS actor2, movies.title
FROM stars s1
JOIN stars s2 ON s2.movie_id = s1.movie_id AND s1.person_id < s2.person_id
JOIN people p1 ON p1.id = s1.person_id
JOIN people p2 ON p2.id = s2.person_id
JOIN movies ON movies.id = s1.movie_id
GROUP BY p1.name, p2.name, movies.title 
HAVING COUNT(*) = 1;

--Find actor pairs who have never acted together in any movie together.
-- GOAL: Find pairs of actors who have NEVER appeared in the same movie

-- STEP 1: Start with all unique actor pairs by self-joining the 'people' table
--         (p1 and p2 represent two different people; use p1.id < p2.id to avoid duplicates and self-pairs)

-- STEP 2: For each actor pair, check if there exists a movie where both actors appeared together
--         This is done by joining the 'stars' table twice (once for each actor)
--         and matching on the same movie_id

-- STEP 3: Use 'NOT EXISTS' to exclude any pair where such a shared movie exists

-- RESULT: Only include actor pairs who do NOT share any movie in common

SELECT p1.name AS actor1, p2.name AS actor2  -- Get the names of two different actors
FROM people p1  -- Start with the first actor from the people table
JOIN people p2 ON p1.id < p2.id  -- Join with a second actor, making sure it's a unique pair (no duplicates or self-pairs)
WHERE NOT EXISTS ( 
    SELECT 1  -- Only include the pair if the following subquery returns no results (i.e., they never acted together) We don’t need actual data, just checking if any row exists
    FROM stars s1  -- Get the movies of the first actor
    JOIN stars s2 ON s1.movie_id = s2.movie_id  -- Look for co-stars in the same movies
    WHERE s1.person_id = p1.id AND s2.person_id = p2.id  -- Filter to just p1 and p2 in the same movie
);  -- End of NOT EXISTS: only include actor pairs who never acted in the same movie





--Write a SQL query to list all unique pairs of actors who were born in the same year.

select p1.name as actor1, p2.name as actor2
from people p1
join people p2 on p2.id < p1.id 
where p1.birth = p2.birth; 


--Find all pairs of actors who have the exact same set of movies. Output: Two columns: actor1, actor2 (names of the actors).

--Problem logic= Classic use of double not exists.
--1. For every pair of actors A and B:
--2. Check: Is there any movie A has done that B hasn’t? (If yes → skip)
--3. Check: Is there any movie B has done that A hasn’t? (If yes → skip)
--4. If both checks pass, they have identical movie sets → keep them!

SELECT p1.name AS actor1, p2.name AS actor2  -- Select the names of the two actors as actor1 and actor2
FROM people p1
JOIN people p2 ON p1.id < p2.id             -- Join people table to itself to get all unique actor pairs (avoid duplicates and self-pairs)
WHERE NOT EXISTS (                          
    SELECT 1                                -- ...any movie where p1 acted but p2 did NOT act
    FROM stars s1
    WHERE s1.person_id = p1.id              -- For movies where actor1 acted
    AND NOT EXISTS (
        SELECT 1
        FROM stars s2
        WHERE s2.person_id = p2.id          -- Check if actor2 acted in the same movie
        AND s2.movie_id = s1.movie_id       -- Match on movie_id
    )
)
AND NOT EXISTS (                           
    SELECT 1                               -- ...any movie where p2 acted but p1 did NOT act
    FROM stars s2
    WHERE s2.person_id = p2.id             -- For movies where actor2 acted
    AND NOT EXISTS (
        SELECT 1
        FROM stars s1
        WHERE s1.person_id = p1.id         -- Check if actor1 acted in the same movie
        AND s1.movie_id = s2.movie_id      -- Match on movie_id
    )
);

-- In SQL, the WHERE clause logically filters rows after all the JOINs have been processed. So even if you write the WHERE condition immediately after the first FROM or after all the joins, it will effectively apply to the result of all joins. You cannot put a WHERE condition inside a JOIN clause unless you write it as part of the ON condition. You can put the WHERE condition anywhere after the joins — the SQL engine will treat it the same way.

--Cheat sheet
--1.	Am I comparing rows in the same table? → Self-join
--2.	Am I looking for something missing? → NOT EXISTS or LEFT JOIN NULL
--3.	Do I want “same set” comparisons? → Double NOT EXISTS
--4.	Am I summarizing or ranking? → GROUP BY or ROW_NUMBER()
--5.	Is this a tree structure or hierarchy? → WITH RECURSIVE



--NB : You can use WHERE for filtering rows before aggregation, but you must use HAVING to filter based on the result of aggregation (like COUNT() or MAX()).

-- Find the name of the actor(s) who have acted in the highest number of movies overall.

select people.name
from stars
join people on people.id = stars.person_id
GROUP BY people.id, people.name
HAVING COUNT(stars.movie_id) = (
  SELECT MAX(movie_count)
  FROM (
    SELECT person_id, COUNT(*) AS movie_count
    FROM stars
    GROUP BY person_id
  ) AS subquery
);

--In SQL, when you use GROUP BY, every column in your SELECT list that is not an aggregate function (like COUNT, SUM, MAX) must be included in the GROUP BY. Even though you’re only displaying people.name, it’s best practice (and sometimes required depending on the database engine) to group by the primary key (people.id) alongside the name to ensure uniqueness.

--Find the names of all actors who have acted in at least one movie released in the same year they were born. .Just one column: name of the actor:

select distinct p1.name
from people p1
join stars s1 on s1.person_id = p1.id 
join movies m1 on m1.id = s1.movie_id 
where m1.year = p1.birth;

--Find all pairs of actors who have appeared together in at least 3 different movies and how many movies they have appeared in together

select p1.name, p2.name, count(*) as movies_together
from stars s1
join stars s2 on s2.person_id < s1.person_id AND s1.movie_id = s2.movie_id
join people p1 on p1.id = s1.person_id
join people p2 on p2.id = s2.person_id
group by p1.name, p2.name having count(*) >= 3
ORDER BY movies_together DESC Limit 5;

--QUESTION: Find the names of actors who have only appeared in one movie — and show the title of that movie.

SELECT people.name, movies.title
FROM stars
JOIN people ON people.id = stars.person_id
JOIN movies ON movies.id = stars.movie_id
WHERE stars.person_id IN (
  SELECT person_id
  FROM stars
  GROUP BY person_id
  HAVING COUNT(*) = 1
);


--solving using self join which isnt the best method-

SELECT p1.name, m1.title
FROM people p1
JOIN stars s1 ON p1.id = s1.person_id
JOIN movies m1 ON m1.id = s1.movie_id
WHERE NOT EXISTS (
    SELECT 1
    FROM stars s2
    WHERE s2.person_id = s1.person_id   -- same actor
      AND s2.movie_id <> s1.movie_id   -- different movie
);

--get s1 and s2, compare the list of stars (s1 and s2) for each movie_id and only return it if they only appear once in the list

--How to tell if a problem requires a self join or not? 1.Ask: Am I comparing rows within the same table? Yes: If you want to compare rows to other rows from the same table (e.g., find pairs of actors who acted together, or find duplicates, or find related rows), then a self join is often the right tool. No: If you are summarizing or filtering based on counts or aggregations per entity (like “actors with only one movie”), you likely don’t need a self join.

--Find all pairs of actors who have acted together in at least 2 movies.

SELECT p1.name AS actor1, p2.name AS actor2, COUNT(*) AS movies_together
FROM stars s1
JOIN stars s2 ON s1.movie_id = s2.movie_id AND s1.person_id < s2.person_id
JOIN people p1 ON p1.id = s1.person_id
JOIN people p2 ON p2.id = s2.person_id
GROUP BY p1.name, p2.name
ORDER BY movies_together DESC;


--Find the top 5 movies with the largest number of actors. outputs = title, year, num_actors who starred in it. order by number of actors descending then by title alphatbically if theres a tie, limit to top 5 results

select movies.title, movies.year, count(stars.person_id) as num_actors
from stars 
join movies on movies.id = stars.movie_id
group by movies.title, movies.year
order by num_actors DESC, movies.title ASC 
Limit 5;

--NB: everytime you use a group by statement, you need to use all the non-aggregate variables you used for the select line. Group by the thing you want counted in the row. i.e we need to group by movie title, so each row is a new movie, with the count listed by each movie.


--Find the actor(s) who have acted in the most number of movies released in the 2000s (from year 2000 to 2009 inclusive). Output two columns: name (actor’s name). movie_count (number of movies they acted in during 2000-2009)

select people.name, count(stars.movie_id) as movie_count
from people
join stars on stars.person_id = people.id
join movies on movies.id = stars.movie_id
where movies.year BETWEEN 2000 and 2009 --where needs to come BEFORE group by
group by people.name --group by all teh variables in the select line that arent aggregated
order by movie_count DESC; 

--Find the actor(s) who have worked with the greatest number of different directors. two columns, name and num_directors

select people.name as actor, count(distinct directors.person_id) as num_directors
from people
join stars on stars.person_id = people.id 
join directors on directors.movie_id = stars.movie_id
group by people.name
order by num_directors DESC;

--Find the titles of all movies that feature at least one actor who also directed the same movie. Ooutput: title and name of the actor-director

SELECT people.name, movies.title
FROM people
JOIN stars ON stars.person_id = people.id 
JOIN movies ON movies.id = stars.movie_id
JOIN directors ON directors.movie_id = movies.id 
WHERE directors.person_id = stars.person_id;

-- Problem:
-- Find the top 3 actors who have appeared in the most movies released between 2010 and 2020 (inclusive).
-- Output columns:
-- actor_name
-- movie_count
-- Order results by movie_count descending

select p1.name as actor_name, count(s1.movie_id) as movie_count
from people p1
join stars s1 on s1.person_id = p1.id
join movies m1 on m1.id = s1.movie_id where m1.year between 2010 and 2020
GROUP BY p1.name
ORDER BY movie_count DESC LIMIT 3; 

-- Find the top 5 directors who have directed the most movies released between 2000 and 2010.
-- Output columns: director_name, movie_count

select person.name as director_name, count(directors.movie_id) as movie_count
from directors
join movies on movies.id = directors.movie_id AND movies.year BETWEEN 2000 and 2010
join people on people.id = directors.person_id
group by director_name
order by movie_count DESC Limit 5;

--must only use WHERE clause after all the joins, or alternatively use AND clause midway through the joins

-- Find the top 5 actors who have appeared in the most movies released between 2015 and 2020.

select p1.name as actor, count(s1.movie_id) as number_of_films
from people p1
join stars s1 on s1.person_id = p1.id 
join movies m1 on m1.id = s1.movie_id AND m1.year BETWEEN 2015 and 2020
group by p1.name
order by number_of_films DESC 
Limit 5;

-- Find the top 3 directors who have directed the most movies released between 2010 and 2020.
-- Return two columns: director_name and movie_count.

select people.name as director, count(directors.person_id) as movie_count
from directors
join people on people.id = directors.person_id
join movies on movies.id = directors.movie_id AND movies.year BETWEEN 2010 AND 2020
group by director -- some sql sofrware dont support using aliases for group by so safter to use people.name here
order by movie_count DESC
limit 3; 

-- 🧠 Problem: Find actors who have appeared in more than 5 movies.
-- Show: actor name and movie count. [group by + having ] 

select p1.name as actor, count(s1.movie_id) as movie_count
from people p1
join stars s1 on s1.person_id = p1.id 
group by p1.name
having count(s1.movie_id) > 5 --must not use the alise in the having line
ORDER BY movie_count DESC;

-- 🧠 Problem: Find actors who have *never* appeared in any movie released in 2020.
-- Show: actor name. [ in and not in ]

select p1.name
from people p1
where not exists ( 
    select 1
    from stars s1 
    join movies m1 on m1.id = s1.movie_id AND m1.year = 2020
    where s1.person_id = p1.id 
);

-- 🧠 Problem (using IN): Find actors who have appeared in movies released **before 2000** 
-- AND have *not* appeared in any movie released **after 2010**.
-- Show: actor name. NB: only one where clause in allowed in the outer query. 

select p1.name as actor
from people p1
where exists (
    select 1
    from stars s1
    join movies m1 on m1.id = s1.movie_id
    where s1.person_id = p1.id
      and m1.year < 2000
)
and not exists (
    select 1
    from stars s2
    join movies m2 on m2.id = s2.movie_id
    where s2.person_id = p1.id
      and m2.year >= 2010
);

--Alternative answer:

SELECT p1.name
FROM people p1
JOIN stars s1 ON s1.person_id = p1.id
JOIN movies m1 ON m1.id = s1.movie_id
WHERE m1.year < 2000
AND p1.id NOT IN (
    SELECT s2.person_id
    FROM stars s2
    JOIN movies m2 ON m2.id = s2.movie_id
    WHERE m2.year >= 2010
);

--anotehr alternative answer using not eixsts: 
SELECT p1.name
FROM people p1
JOIN stars s1 ON s1.person_id = p1.id
JOIN movies m1 ON m1.id = s1.movie_id
WHERE m1.year < 2000
AND NOT EXISTS (
    SELECT 1
    FROM stars s2
    JOIN movies m2 ON m2.id = s2.movie_id
    WHERE s2.person_id = p1.id AND m2.year >= 2010
);

-- 🧠 Problem: Find all actors who have *never* worked with director Christopher Nolan.
-- Show: actor name

SELECT p1.name AS actor
FROM people p1
WHERE NOT EXISTS (
    SELECT 1
    FROM stars s1
    JOIN movies m1 ON m1.id = s1.movie_id
    JOIN directors d1 ON d1.movie_id = m1.id
    JOIN people p2 ON p2.id = d1.person_id AND p2.name = 'Christopher Nolan'
    WHERE s1.person_id = p1.id
);


-- 🧠 Problem: Find actors who have appeared in *every* movie directed by "Quentin Tarantino".
-- Show: actor name. NB: EXISTS is to find "at least one", not exists is to find ALL

--NB: FILTER FOR THE ACTUAL THING YOU CARE ABOUT IN THE SUBQUERY. THEN NOT EXIST ABOVE IT AUTOMATICALLY EXCLUDES THE RESULT IF IT DOESNT MEET THE CONDITION YOU WANT.

SELECT p1.name AS actor
FROM people p1 --first subquery looks at every movie tarantino directed
WHERE NOT EXISTS ( 
    SELECT 1
    FROM movies m
    JOIN directors d ON d.movie_id = m.id
    JOIN people p2 ON p2.id = d.person_id
    WHERE p2.name = 'Quentin Tarantino' -- second subquery checks if that actor was not in that movie
      AND NOT EXISTS (
          SELECT 1
          FROM stars s
          WHERE s.movie_id = m.id
            AND s.person_id = p1.id --if there is no such movie that the actor missed, then that actor is included in the final result
      )
);

-- 🧠 Problem: Find all directors who have *never* directed a movie after the year 2015.
-- 🎯 Show: director name.

SELECT p1.name AS director
FROM people p1
WHERE EXISTS (
    SELECT 1
    FROM directors d
    WHERE d.person_id = p1.id
)
AND NOT EXISTS (
    SELECT 1
    FROM directors d
    JOIN movies m ON m.id = d.movie_id
    WHERE d.person_id = p1.id
      AND m.year > 2015
);
--filter on the condition you care about, and not exists filters out anythign thatdoesnt match that 

-- 🧠 Problem: Find all *actors* who have starred in *every movie* directed by Christopher Nolan.
-- 📌 Show: actor name.

--outer = Is there any Nolan-directed movie this person is not in?”
--first subquery: Filters for only Nolan movies
--second subquery: for each nolan movie, check if the actor is not in that movie

--NB: Cant use a AND on same line as a JOIN, so need to seperate the line and put WHERE

--correlation is when somethign in a subquery mentions a column specified in the outter query?
--my question:"if i dont mention people.id in the outer query but only have people.name in the outer query, but then mention people.id in the subquery, is it still correlated because people.id and people.name are within the same table?"
--Yes! Correlation depends on referencing a column from the outer query’s current row, regardless of whether you selected that column explicitly in the outer query’s SELECT clause.

SELECT p1.name AS actor
FROM people p1
WHERE NOT EXISTS (
    SELECT 1
    FROM movies m --this table flows through to the second subquery i.e only Nolan directed films
    JOIN directors d ON d.movie_id = m.id
    JOIN people p2 ON p2.id = d.person_id 
    WHERE p2.name = 'Christopher Nolan'
      AND NOT EXISTS (
          SELECT 1
          FROM stars s
          WHERE s.movie_id = m.id
            AND s.person_id = p1.id
      )
);

-- 🧠 Problem:
-- Find all actors who have appeared in *every* movie released in the year 2019.

select p1.name as actor
from people p1
where not exists (
    select 1
    from movies m1
    join stars s1 on s1.movie_id = m1.id 
    where m1.year = 2019
    and not exists (
        select 1
        from stars s2
        where m1.id = s2.movie_id --m1 flows down from the first subquery
        and s2.person_id = p1.id --i.e need to connect this back to the outter query checking if the p1 person starred in this s2 movie
    )
);

--Find actors who have never appeared in any movie directed by “Steven Spielberg”.
--outter query is actors
--first subquery find all steven spielberg films
--second subquery starred in any of the above spielberg films that flow through

select p1.name as actor
from people p1
where not exists (
    select 1
    from directors d1
    join stars s1 on s1.movie_id = d1.movie_id
    join people p2 on p2.id = d1.person_id
    WHERE p2.name = "Steven Spielberg"
    and not exists (
        select 1
        from stars s2
        where s1.movie_id = s2.movie_id
        AND s2.person_id = p1.id
    )
);

--Find all actors who have appeared in every movie released in 2010.

select p1.name as actor
from people p1
where not exists (
    select 1
    from movies m1
    join stars s1 on s1.movie_id = m1.id
    where m1.year = 2010
    and not exists (
        select 1
        from stars s2
        where s2.movie_id = s1.movie_id --for clarity, could put s2.movie_id = m1.id instead
        AND s2.person_id = p1.id
    )   
);


--Find the names of actors who have never starred in a movie that has the word “Love” in its title. i.e find all movies with love in it, check if any actor starred in any one of them (i.e exists), if they dont, include them in list.


select p1.name
from people p1
where not exists (
    select 1
    from movies m1
    where m1.title LIKE 'Love%' -- if movie doesnt have love in title, it doesnt pass this point, if it does have love in title, the second subquery will run below.
    and exists (
        select 1
        from stars s1
        where s1.movie_id = m1.id 
        AND s1.person_id = p1.id  --check if person p1 acted in that movie wihch must contain 'Love', if they did act in it, return a '1' to the first subquery, which at that point sees its true and excludes it (as it needs a zero then zero to be true and exclude the row)
    )
);
        
-- Simple terms: the first subquery looks for any movie with title LIKE 'Love%' 
--     AND checks (via the second subquery) whether this person acted in it.
--     If the movie title doesn’t contain 'Love', the second subquery doesn't run for that movie.
-- If such a movie EXISTS → subquery returns something → NOT EXISTS is false → ❌ exclude this person.
-- If no such movie EXISTS → subquery returns nothing → NOT EXISTS is true → ✅ include this person.

--LLANIS NOTES: if movie doesnt contains love, ignore, go to next movie. if contains love, check if they starred in it, if starred , exclude, if not starred, include.

/* 1.	We’re looping through every person (p1) in people.
	2.	For each person, we ask:
❓“Does there exist a movie starting with ‘Love’ where this person acted (whilst we dont have stars in the first subquery, the second subquery is nested within the first subquery so we can effectively pair them?”
	3.	To answer that, we:
	•	Search movies where title LIKE 'Love%'
	•	Then, for each of those movies, we ask in the inner subquery:
❓“Did this person (p1) star in that movie?”
	4.	If yes, then the EXISTS returns true → the outer NOT EXISTS becomes false → ❌ exclude them.
	5.	If no, meaning there are no such matches, then the person is ✅ included. */



-- Outer query: loops over each person (p1)

-- First subquery: checks for any movie with a title starting with 'Love%'
-- If NO such movie exists that this person acted in (i.e. second subquery never returns true) → first subquery returns nothing → NOT EXISTS is TRUE → include the row
-- If a 'Love%' movie exists, move to second subquery:

    -- Second subquery: checks if that person (p1) acted in that 'Love%' movie
    -- If TRUE (1): person DID act in the 'Love%' movie → EXISTS returns a row → first subquery returns a row → NOT EXISTS is FALSE → exclude the row
    -- If FALSE (0): person did NOT act in the 'Love%' movie → EXISTS returns nothing → first subquery returns nothing → NOT EXISTS is TRUE → include the row

-- Summary:
-- ✅ Include the person only if they did NOT act in ANY movie where the title starts with 'Love'
-- ❌ Exclude the person if they acted in at least one movie where the title starts with 'Love'


--find any stars of any of those movies i.e if they starred in atleast one, exclude them 

--Actors Who Never Starred in a Movie Released After 2015 (i.e find all movies after 2015, check if an actor starred in those, if they did, exclude them

select p1.name as actor
from people
where not exists (
    select 1
    from movies m1
    where m1.year >= 2015
    and exists (
        select 1
        from stars s1
        where s1.movie_id = m1.id 
        and s1.person_id = p1.id 
    )
);

-- Window Functions in SQL: let you perform calculations across a “window” of rows that are related to the current row, without collapsing the result like a GROUP BY would. i.e “Do this calculation, but only over this group of rows, and keep all the rows in the output.” Key Characteristics: 
--They return a value for each row — unlike aggregation (GROUP BY), which returns one row per group.
--The “window” is defined using the OVER() clause.
--Inside OVER() you can use:
	-- PARTITION BY → to break the data into groups (like “per actor”, “per customer”, etc.)
	-- ORDER BY → to define the order of rows inside each group
    -- Common Window Functions in SQL:

-- ROW_NUMBER(): Assigns a unique row number within each partition (no ties).
-- RANK(): Assigns ranks with gaps in case of ties (e.g., 1, 2, 2, 4).
-- DENSE_RANK(): Assigns ranks without gaps for ties (e.g., 1, 2, 2, 3).
-- SUM(): Returns the sum over the window (can be running total or group total).
-- AVG(): Returns the average over the window.
-- COUNT(): Counts rows in the window.
-- LAG(): Returns the value from the previous row in the window.
-- LEAD(): Returns the value from the next row in the window.
-- FIRST_VALUE(): Returns the first value in the window.
-- LAST_VALUE(): Returns the last value in the window.

-- Usage pattern:
-- SELECT ..., window_function(...) OVER (
--     PARTITION BY ...
--     ORDER BY ...
-- ) AS result_name
-- FROM table;

--LLANI NOTE: Group by is like draggin a variable to the 'rows' section on the far left of the pivot table so everythign is grouped by that variable. where as partion by is like dragging that same variable in to the rows area, but also keepgin the detailed data intact, (almost like applying a formula within each group), it doesn't remove rows, it virtually groups the rows but still keeps every individual row.
--THE WINDOW FUNCTOIN ALWAYS GOES IN THE SELECT LIST.


--Q1: “For each actor, show the year of each movie they acted in, the movie title, and how many movies they had been in up to and including that year.”

select 
  p1.name as actor, 
  m1.title as movie, 
  m1.year as movie_year,
  COUNT(m1.id) OVER (PARTITION BY p1.id ORDER BY m1.year) as running_total
from movies m1
join stars s1 on s1.movie_id = m1.id 
join people p1 on p1.id = s1.person_id
order by p1.name, m1.year;

--Q2: For each actor, list their movies along with the rank of the movie by release year (most recent movie is rank 1). Sort the output by actor name and rank.

select 
    p1.name as actor, 
    m1.title as movie, 
    m1.year as release_date, 
dense_rank() over (
    PARTITION by p1.id 
    order by m1.year DESC
    ) AS movie_rank
from movies m1
join stars s1 on s1.movie_id = m1.id 
join people p1 on p1.id = s1.person_id
ORDER BY p1.name, movie_rank;

-- 🧠 Q3: Top 3 Most Recent Movies Per Actor
-- For each actor, list their 3 most recent movies.
-- Output should include:
--   - actor name
--   - movie title
--   - movie year
--   - movie rank (1 = most recent, per actor)

--LANI NOTE: -- COUNT(col) needs a column inside () because it's counting values.
-- DENSE_RANK(), RANK(), and ROW_NUMBER() leave () empty — they rank rows based on ORDER BY inside OVER().
-- Use COUNT(col) for totals; use DENSE_RANK()/RANK()/ROW_NUMBER() to assign row positions.

SELECT
    p1.name AS actor,
    m1.title AS movie,
    m1.year AS year,
    DENSE_RANK() OVER (
        PARTITION BY p1.id
        ORDER BY m1.year DESC
    ) AS movie_rank
FROM movies m1
JOIN stars s1 ON s1.movie_id = m1.id 
JOIN people p1 ON p1.id = s1.person_id
WHERE m1.year IS NOT NULL
QUALIFY movie_rank <= 3 -- ❗Not supported in SQLite. See below for workaround.
ORDER BY p1.name ASC, movie_rank;

SELECT *--these first two lines are added to make outter query
FROM (
    SELECT --here downwards is the standard answer but needs to be put in as a subquery
        p1.name AS actor,
        m1.title AS movie,
        m1.year AS year,
        DENSE_RANK() OVER (
            PARTITION BY p1.id
            ORDER BY m1.year DESC
        ) AS movie_rank
    FROM movies m1
    JOIN stars s1 ON s1.movie_id = m1.id 
    JOIN people p1 ON p1.id = s1.person_id
) 
WHERE movie_rank <= 3 -- now you can select all the rows up unti lrank 3
ORDER BY actor, movie_rank; -- order by is moved from inner subquery to outside so functions the same 
    
-- Q4 Actors With the Most Movies in a Single Year

-- 🎯 Goal:
-- For each actor, find the year in which they starred in the most movies.
-- Show: actor's name, the year, and how many movies they starred in that year.

-- 🧾 Output Columns:
-- actor | year | movie_count

-- ✅ Order by:
-- actor (A–Z), then year (most recent first


SELECT 
    p.name AS actor,
    m.title AS movie,
    m.year AS release_year,
    COUNT(m.id) OVER (
        PARTITION BY p.id
        ORDER BY m.year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW 
    ) AS running_total -- abobe not needed in sqlite
FROM people p
JOIN stars s ON s.person_id = p.id
JOIN movies m ON m.id = s.movie_id
ORDER BY p.name, m.year;

--Q5: PROBLEM: For each actor, list their movies along with how many movies they acted in **per decade**.
-- Show: actor name, movie title, release year, decade, and the number of movies they did in that decade.

SELECT
  p.name AS actor,               -- Actor's name
  m.title AS movie,              -- Movie title
  m.year AS release_year,        -- Movie release year
  (m.year / 10) * 10 AS decade_start,  -- Calculate the decade start (e.g., 1990 for 1995)
  
  -- Window function: counts number of movies for this actor in this decade
  COUNT(m.id) OVER (
    PARTITION BY p.id, (m.year / 10) * 10 
  ) AS movies_per_decade           -- Number of movies actor has in this decade, above resetst teh count every decade

FROM people p                    
JOIN stars s ON s.person_id = p.id   
JOIN movies m ON m.id = s.movie_id    
ORDER BY p.name, decade_start, m.year;  -- Order by actor, then decade, then movie year

-- Q6 PROBLEM:
-- For each actor, list their name, the movie title, release year,
-- and the rank of the movie in that actor’s career by release year (most recent movie = 1).
--
-- Output columns: actor_name, movie_title, release_year, movie_rank
-- Sort results by actor_name ascending, then movie_rank ascending.

--LLANI NOTE: PARTITION BY resets teh calculation per partition, partition by + order by, resets per group, and does row by row ops

SELECT
    p1.name as actor,
    m1.title as movie,
    m1.year as year,
    dense_rank() OVER (
        PARTITION by p1.id, m1.year
        ORDER BY DESC
        ) AS movie_rank
from movies m1
join stars s1 on s1.movie_id = m1.id 
join people p1 on p1.id = s1.person_id
ORDER BY p1.name ASC, movie_rank ASC


-- For each actor, list their movies in the order they were released,
-- and calculate a running total of how many movies they have appeared in **up to that point**.

SELECT
    p1.name,
    m1.title,
    count(m1.id) over (
        partition by p1.id
        Order by m1.year ASC
    ) as movie_count
from movies m1
join stars s1 on s1.movie_id = m1.id 
join people p1 on p1.id = s1.person_id
ORDER BY p1.name ASC

-- PROBLEM:
-- For each movie released after 2000, list the movie title, release year, and for each actor in that movie,
-- show the actor’s name and the number of movies they have acted in **up to and including that movie’s release year**.
-- Order the output by movie release year ascending, then movie title, then actor name.

-- Expected columns: movie_title, release_year, actor_name, movies_count_up_to_year

select 
    p1.name as actor,
    m1.title as movie,
    m1.year as year,
    count(m1.id) over (
        partition by p1.id 
        order by m1.year ASC
        ) as movie_count
from movies m1
join stars s1 on s1.movie_id = m1.id 
join people p1 on p1.id = s1.person_id
WHERE m1.year > 2000
ORDER BY p1.name ASC, m1.year ASC, movie_count;

-- PROBLEM:
-- For each actor, list their movies along with the total number of movies they acted in 
-- up to (and including) that movie’s release year, **per decade**.
-- Show columns: actor, movie, release_year, decade_start, running_total_per_decade.
-- Order by actor name, decade_start ascending, then release_year ascending.

select 
    p1.name as actor,
    m1.title as movie,
    m1.year as release_year,
    (m1.year / 10) * 10 as decade_start,
    count(m1.id) over (
        PARTITION BY p1.id, (m1.year / 10) * 10
        ORDER BY m1.year
        ) as running_total_per_decade
from movies m1
join stars s1 on s1.movie_id = m1.id 
join people p1 on p1.id = s1.person_id
ORDER BY p1.name ASC, decade_start ASC, release_year;


-- PROBLEM:
-- For each actor, list the first movie they acted in *each decade*.
-- Include: actor name, movie title, release year, and the decade.
-- Output should be ordered by actor name, then decade.

select *
from (
    select 
        p1.name as actor,
        m1.title as movie,
        m1.year as year,
        (m1.year / 10) * 10 as decade_start,
        rank() OVER (
        PARTITION BY p1.id, (m1.year / 10) * 10
        ORDER BY m1.year ASC
        ) as rank
    from movies m1
    join stars s1 on s1.movie_id = m1.id 
    join people p1 on p1.id = s1.person_id
)
WHERE rank = 1
ORDER BY p1.name ASC, decade_start ASC, year ASC


-- For each actor, find how many movies they acted in before the year 2000 
-- and how many movies they acted in from 2000 onwards.
-- Show actor name, count_before_2000, count_2000_and_after.

select
    p1.name as actor,
    count(case when m1.year < 2000 then 1 END) as movies_to_1999,
    count(case when m1.year >= 2000 then 1 END) as movies_from_2000
from movies m1
join stars s1 on s1.movie_id = m1.id 
join people p1 on p1.id = s1.person_id
group by p1.name
order by p1.name;

-- For each actor, count how many movies they acted in each decade.
-- Display actor name, decade (e.g., 1990, 2000), and number of movies in that decade.
-- Order results by actor name and decade ascending.

select 
    p1.name as actor,
    (m1.year / 10) * 10 as decade_start.

SELECT
  p1.name as  actor,
  (m1.year / 10) * 10 AS decade,
  COUNT(m1.id) AS movies_count
FROM movies m1
JOIN stars s1 ON s1.movie_id = m1.id
JOIN people p1 ON p1.id = s1.person_id
GROUP BY p1.name, decade
ORDER BY p1.name, decade;

--List all actors who acted in more than one movie in the same year.

--LLANI NOTE  COUNT(*) counts all rows, regardless of column values.
-- Use it when each row represents what you want to count (e.g. one movie per row).
-- If rows represent combinations (e.g. actor–movie), COUNT(*) counts each combo.
-- To avoid overcounting, use COUNT(DISTINCT ...) if needed.

select 
    p1.name as actor
    m1.year,
    count(*) as movies_in_year
from people p1
join stars s1 on s1.person_id = p1.id
join movies m1 on m1.id = s1.movie_id
GROUP BY p1.id, p1.name, m1.year --can also inlcude p1.id to ensure uniqueness so people with same name arent mistakenly counted even though it wasnt in thet select line
HAVING count(*) > 1; -- having is for conditions on aggregated values only (i.e count, sum, etc, not raw columns. Conditions on raw (non aggregated) columns should go in there WHERE clause before the GROUP BY. Where can't be used on aggregated values


--LLANI NOTE:  Key Distinction: 
-- WHERE = filters individual rows *before* aggregation (raw data level)
-- GROUP BY = groups rows for aggregation (eg per actor, per year)
-- HAVING = filters *after* aggregation (e.g., COUNT, SUM, etc.)

--For each actor, count how many movies acted in before year 2000, and 2000+

SELECT 
    p1.name AS actor,
    COUNT(CASE WHEN m1.year < 2000 THEN 1 END) AS movies_pre_2000,
    COUNT(CASE WHEN m1.year >= 2000 THEN 1 END) AS movies_2000_onwards
FROM movies m1
JOIN stars s1 ON s1.movie_id = m1.id 
JOIN people p1 ON p1.id = s1.person_id
GROUP BY p1.name
ORDER BY p1.name;

--For each actor, show the total number of movies they’ve starred in, and how many of those were released in odd-numbered years.

SELECT 
    p1.name as actor,
    count(m1.id) as movie_count,
    count(CASE WHEN m1.year % 2 = 1 THEN 1 END) as odd_movie_count
FROM movies m1
JOIN stars s1 ON s1.movie_id = m1.id 
JOIN people p1 ON p1.id = s1.person_id
GROUP BY p1.name
ORDER BY p1.name;

--For each actor, show the total number of movies they’ve acted in, how many were released before 2010, and what percentage of their movies were released before 2010

SELECT
    p1.name as actor,
    count(m1.id) as total_movies,
    count(CASE WHEN m1.year < 2010 THEN 1 END) as movies_pre_2010,
    round(( count(CASE WHEN m1.year < 2010 THEN 1 END) * 1.0 / count(m1.id)) * 100, 1) as percentage_pre_2010 -- need * 1.0 to force it to do decimal division rather than interger division which would otherwise result in a zero, because 3/5 = 0, but 3 * 1.0 / 5 = 0.6, alternatively could do: Cast(3 as float) / 5
FROM movies m1
JOIN stars s1 ON s1.movie_id = m1.id 
JOIN people p1 ON p1.id = s1.person_id
GROUP BY p1.name
ORDER BY p1.name;

--For each actor, divide their filmography into 3 equal-sized groups (early, middle, late career) based on movie release year. 

SELECT
    p.name AS actor,
    m.title AS movie,
    m.year,
    NTILE(3) OVER (
        PARTITION BY p.id
        ORDER BY m.year
    ) AS career_phase
FROM people p
JOIN stars s ON s.person_id = p.id
JOIN movies m ON m.id = s.movie_id
ORDER BY p.name, career_phase, m.year;

--Classify each actor’s movies into “Early Career”, “Mid Career”, or “Late Career” buckets (based on release year) and show how many movies they did in each phase. Show: actor name, career phase label, and number of movies in that phase. Order alphabetically by actor name and by career phase in logical order.

WITH career_phases AS (
    SELECT
        p.name AS actor,
        NTILE(3) OVER (
            PARTITION BY p.id
            ORDER BY m.year
        ) AS phase
    FROM people p
    JOIN stars s ON s.person_id = p.id
    JOIN movies m ON m.id = s.movie_id
)
SELECT
    actor,
    CASE phase
        WHEN 1 THEN 'Early Career'
        WHEN 2 THEN 'Mid Career'
        WHEN 3 THEN 'Late Career'
    END AS career_phase,
    COUNT(*) AS movies_in_phase
FROM career_phases
GROUP BY actor, phase
ORDER BY actor, phase;

--NB NOTE: inner most query is evaluated first, then works its way outwards. Behidn the scenes, SQL works like this: 

--1. FROM       ← including joins and subqueries in FROM
--2. WHERE      ← filters rows before grouping
--3. GROUP BY   ← creates row groups
--4. HAVING     ← filters groups
--5. SELECT     ← calculates expressions and aliases
--6. ORDER BY   ← sorts results
--7. LIMIT/OFFSET (optional)

--CTE AND CASE PROBLEMS: Q1 - List all actors who acted in more than 3 movies, and also show how many were before 2010 and after.

WITH movie_count as ( 
    select
        p1.name as actor,
        count(m1.id) as total_movies,
        count(CASE WHEN m1.year < 2010 THEN 1 END) as movies_before_2010,
        count(CASE WHEN m1.year >= 2010 then 1 END) as movies_2010_onwards
    FROM 
        people p1
    JOIN stars s1 ON s1.person_id = p1.id 
    JOIN movies m1 ON m1.id = s1.movie_id
    GROUP BY p1.name
)
select
    actor,
    total_movies,
    movies_before_2010,
    movies_2010_onwards
FROM movie_count
WHERE total_movies > 3
ORDER BY total_movies DESC;


--List the top 2 most prolific actors (by number of movies starred in) for each year.
--Show: the actor’s name, the year, the number of movies they acted in that year, and their rank for that year.
--If there’s a tie, include all actors at that rank (e.g., if 3 actors tied for #1, show all 3, and skip #2).


WITH actor_year_counts AS (
    SELECT
        p.name AS actor,
        m.year,
        COUNT(*) AS movies_in_year
    FROM people p
    JOIN stars s ON s.person_id = p.id
    JOIN movies m ON m.id = s.movie_id
    GROUP BY p.name, m.year
),
ranked_actors AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY year ORDER BY movies_in_year DESC) AS rank
    FROM actor_year_counts
)
SELECT
    year,
    actor,
    movies_in_year,
    rank
FROM ranked_actors
WHERE rank <= 2
ORDER BY year ASC, rank ASC;

--LLANI NOTE: -- The final SELECT queries only the last CTE i.e a table called ranked_actors but as the second CTE references the first CTE, their data flows through indirectly.
-- So final SELECT sees data from all CTEs used in the chain, but can only directly access the last CTE in the WITH clause. i.e You cannot directly reference the name of the first CTE in the final query if you have multiple CTEs chained together. But that’s not a problem because the last CTE usually selects and passes along all the columns or aliases you need from earlier CTEs.


--	•	The first CTE builds a temporary result set (like a mini-table) — for example, actor_year_counts contains columns like actor, year, and movies_in_year. The second CTE references that first CTE as if it’s a table. It can use all the columns from the first CTE, and create new columns or filter/transform the data, effectively building a new mini-table. What flows from the first to the second CTE is the entire result set produced by the first CTE. So the second CTE gets a snapshot of that data and can do whatever it wants next.

--RANK() is ALWAYS paried with OVER (but not necessarily partition)

--List the top 3 actors with the most movies in each decade (e.g., 1990–1999, 2000–2009, 2010–2019). Show actor name, decade, and movie count.

with appearances_decades_count as (
    SELECT 
    (m1.year / 10) * 10 as decade_start,
    p1.name as actor,
    count(m1.id) as movie_count
    From people p1
    join stars s1 on s1.person_id = p1.id 
    join movies m1 on m1.id = s1.movie_id
    GROUP BY actor, decade_start -- i.e how many movies each actor appeared in per decade
), ranked_actors as (
    select 
    *,
    rank() over (partition by decade_start order by movie_count DESC) as rank
    from appearances_decades_count --ie for each decade, rank the number of movies an actor has done compared with other actors
)
select 
    decade_start,
    actor,
    movie_count
FROM ranked_actors
where rank <= 3
ORDER BY decade_start, rank;

--Find all actors who acted in more movies in the 2000s (2000–2009) than in the 2010s (2010–2019). Show their name, how many movies they did in the 2000s, and how many in the 2010s.

WITH appearances AS (
    SELECT 
        p1.name AS actor,
        COUNT(CASE WHEN m1.year >= 2000 AND m1.year < 2010 THEN 1 END) AS movies_2000s,
        COUNT(CASE WHEN m1.year >= 2010 AND m1.year < 2020 THEN 1 END) AS movies_2010s
    FROM people p1
    JOIN stars s1 ON s1.person_id = p1.id 
    JOIN movies m1 ON m1.id = s1.movie_id
    GROUP BY p1.name
)
SELECT *
FROM appearances
WHERE movies_2000s > movies_2010s
ORDER BY movies_2000s DESC ;

--For each year, find the actor who appeared in the most movies. Show the year, actor name, and number of movies.

with appearances as (
    SELECT
        m1.year as year,
        p1.name as actor,
        count(m1.id) as appearance_number
    from people p1
    join stars s1 on s1.person_id = p1.id 
    join movies m1 on m1.id = s1.movie_id
    GROUP BY p1.name, m1.year --cant use alaises in group by statements 
), rankings as (
    select 
        *,
        rank() over (PARTITION BY year ORDER BY appearance_number DESC) as rank
    FROM appearances
)
select *
FROM rankings
where rank = 1
order by year ASC;

--Find the top 2 directors with the highest number of movies in each decade.

with movies_per_decade_by_director as (
    select 
        (m1.year / 10) * 10 as decade_start,
        p1.name as director,
        count(m1.id) as movie_count
    From people p1
    JOIN directors d1 on d1.person_id = p1.id
    join movies m1 on m1.id = d1.movie_id
    GROUP BY p1.name, decade_start
),
ranked_directors_per_decade as (
    select 
    *,
    dense_rank() over (PARTITION BY decade_start ORDER BY movie_count DESC) as rank
    FROM movies_per_decade_by_director
)
select 
    decade_start,
    director,
    movie_count, 
    rank
FROM ranked_directors_per_decade
where rank <= 2
ORDER BY decade_start ASC, rank ASC;

--Find the top 3 actors with the most total movie appearances per decade (grouped by decade across all years).

with appearances_per_decade as (
    SELECT 
    (m1.year / 10) * 10 as decade_start,
    p1.name as actor,
    count(m1.id) as movies
    FROM
    people p1 
    JOIN stars s1 on s1.person_id = p1.id 
    JOIN movies m1 on m1.id = s1.movie_id
    GROUP BY p1.person, (m1.year / 10) * 10
), rankings as (
    select
    *,
    dense_rank() over (partition by decade_start ORDER BY movies DESC) as rank
    FROM appearances_per_decade
)
select
    *
FROM rankings
WHERE rank <= 3
ORDER BY decade_start, rank;



--LLANI NOTE = JUST BECAUSE WE GROUPED BY decade_start earlier does not mean it is automatic for the dense_rank function, we still need to specify where to start ranking from again (i.e partition by each decade)
--When you GROUP BY decade_start, you get one row per actor per decade, showing how many movies they appeared in during that decade.

--PARTITION BY
--Used in window functions like RANK(), DENSE_RANK(), ROW_NUMBER()
--Does not reduce rows — just adds new values (like rank) to each row
--Divides data into windows/groups only for the window function — e.g., to say “rank actors within each decade”

--Find the pair of actors who appeared in the most movies together in each decade.

with movies_per_decade as (
    SELECT
        (m1.year / 10) * 10 as decade_start,
        p1.name as actor1,
        p2.name as actor2,
        count(m1.id) as movie_count
    FROM people p1
    JOIN stars s1 on s1.person_id = p1.id 
    JOIN movies m1 on m1.id = s1.movie_id
    JOIN stars s2 on s2.movie_id = s1.movie_id AND s1.id < s2.id
    JOIN people p2 on p2.id = s2.person_id
    GROUP BY decade_start, actor1, actor2
), 
rankings as (
    SELECT
        *,
        rank() over (PARTITION BY decade_start ORDER BY movie_count DESC) as rank
    FROM movies_per_decade
)
SELECT
    *
FROM rankings
WHERE rank = 1
ORDER BY decade_start; -- note, no need for a comma after the last CTE

--For each year, find the actor who co-starred with the most unique actors across all movies that year.

WITH costars_per_year AS (
    SELECT
        m.year,
        p1.name AS actor,
        COUNT(DISTINCT s2.person_id) AS unique_costars
    FROM stars s1
    JOIN stars s2 ON s1.movie_id = s2.movie_id AND s1.person_id != s2.person_id
    JOIN people p1 ON p1.id = s1.person_id
    JOIN movies m ON m.id = s1.movie_id
    GROUP BY m.year, p1.name
),
rankings AS (
    SELECT *,
           RANK() OVER (PARTITION BY year ORDER BY unique_costars DESC) AS rank
    FROM costars_per_year
)
SELECT *
FROM rankings
WHERE rank = 1
ORDER BY year;

-- Use `s1.person_id != s2.person_id` to count all co-stars for each actor individually.
-- Use `s1.person_id < s2.person_id` only when counting unique actor pairs to avoid duplicates.

--Find the director-actor pair that worked together the most times in each decade. If there’s a tie, return all top pairs.

WITH pairings_per_decade AS (
    SELECT
        (m1.year / 10) * 10 AS decade_start,
        p1.name AS actor,
        p2.name AS director,
        COUNT(m1.id) AS movie_count
    FROM people p1
    JOIN stars s1 ON s1.person_id = p1.id
    JOIN directors d1 ON d1.movie_id = s1.movie_id
    JOIN movies m1 ON m1.id = s1.movie_id
    JOIN people p2 ON p2.id = d1.person_id
    GROUP BY decade_start, actor, director
), rankings AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY decade_start ORDER BY movie_count DESC) AS rank
    FROM pairings_per_decade
)
SELECT *
FROM rankings
WHERE rank = 1   -- only top-ranked pairs per decade
ORDER BY decade_start, movie_count DESC;


--if they worked together more than once, that still only counts as one so distcint count
--coutn when movie id matches for each pair, but their person ids are less than each other (i.e that counts each unique pairing)

--Find the top 2 actors with the highest number of movie appearances per year.

with appearances_per_year as (
    SELECT
        m1.year as year,
        p1.name as actor,
        count(m1.id) as appearances -- alaises arent available here either
    FROM people p1
    JOIN stars s1 on s1.person_id = p1.id 
    join movies m1 on m1.id = s1.movie_id
    GROUP BY m1.year, p1.name --alaises are not available here
    ), 
rankings as (
    SELECT
        *,
        rank() over (partition by year ORDER BY appearances DESC) as rank --must use aliases here
    FROM appearances_per_year
)
SELECT
    *
From rankings
WHERE rank <= 2
ORDER BY year ASC; --must use aliases here

--Find the top 5 actors who have worked with the most unique director

with pairings as (
    SELECT
        p1.name as actor,
        p2.name as director,
    FROM people p1
    JOIN stars s1 on s1.person_id = p1.id 
    JOIN movies m1 on m1.id = s1.movie_id
    JOIN directors d1 on d1.movie_id = m1.id 
    JOIN people p2 on p2.id = d1.person_id
), 
select 
    actor,
    count(distinct director) as number_of_directors
FROM pairings
GROUP by actor
ORDER by number_of_directors DESC
LIMIT 5;
    
--Which actor has appeared in the most movies each decade

with appearances as (
    SELECT
        (m1.year / 10) * 10 as decade_start,
        p1.name as actor,
        count(m1.id) as appearance
    FROM people p1
    JOIN stars ON s1.person_id = p1.id 
    JOIN movies ON m1.id = s1.movie_id
    GROUP BY p1.name, (m1.year / 10) * 10
), rankings as (
    SELECT
        *,
        rank() over (partition by decade_start ORDER BY appearance DESC) as rank
    FROM appearances
)
select *
FROM rankings
WHERE rank = 1
ORDER BY decade_start;

--For each actor, find the one person they have co-starred with the most times, across all years. 

WITH pairings AS (
    SELECT
        p1.name AS actor1,
        p2.name AS actor2
    FROM people p1
    JOIN stars s1 ON s1.person_id = p1.id
    JOIN stars s2 ON s2.movie_id = s1.movie_id AND s1.person_id < s2.person_id
    JOIN people p2 ON p2.id = s2.person_id --this table automatically excludes movies with 1 actor has it needs to have a second star
),
movie_counts AS (
    SELECT
        actor1,
        actor2,
        COUNT(*) AS number_of_movies
    FROM pairings
    GROUP BY actor1, actor2
),
ranked_pairs AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY actor1 ORDER BY number_of_movies DESC) AS rank
    FROM movie_counts
)
SELECT
    actor1, --must manually select the variables because if we used * we'd pull rank through as a column which we dont want
    actor2,
    number_of_movies
FROM ranked_pairs
WHERE rank = 1
ORDER BY actor1;
