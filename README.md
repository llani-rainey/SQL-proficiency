# SQL Practice Repository (Movies Database)

A collection of SQL queries written to strengthen practical SQL skills using a relational “movies” dataset (tables such as `people`, `movies`, `stars`, `directors`). The focus is on solving increasingly complex problems using multiple query strategies (e.g., `IN` vs `EXISTS` vs self-joins) and explaining the reasoning behind each approach. See 13.sql for the majority of the queries whereby the increase in difficulty.

## What this repo demonstrates

- Ability to translate plain-English requirements into correct SQL
- Comfort with relational modelling and join paths (e.g., people ↔ stars ↔ movies, directors ↔ movies)
- Multiple solution patterns for the same problem, with trade-offs noted (readability vs performance vs portability)
- Query correctness details: de-duplication, avoiding mirrored pairs, excluding the reference actor, handling ties, etc.

## Concepts covered

### Joins
- `INNER JOIN` across multiple tables to connect entities
- **Self-joins** (especially on `stars`) to find co-stars / actor pairs
- Join predicates for uniqueness (e.g., `s1.person_id < s2.person_id` to avoid duplicate mirrored pairs)

### Filtering & set logic
- `WHERE` filtering vs `HAVING` filtering after aggregation
- `IN` subqueries for membership tests
- `EXISTS` / `NOT EXISTS` for “at least one” / “none” logic
- “Same set” comparisons using **double `NOT EXISTS`** (set equality)

### Aggregation
- `GROUP BY` with `COUNT`, `COUNT(DISTINCT ...)`
- Filtering aggregates with `HAVING`
- Ranking “top N” patterns using aggregation + ordering
- Tie handling using rank-based approaches

### Common query patterns implemented
- **Co-star queries** (e.g., “everyone who starred with Kevin Bacon (born 1958)”, excluding Kevin Bacon)
- **Actor pair analysis**
  - pairs who appeared together in >1 movie
  - pairs who appeared together in exactly one movie (including the specific movie title)
  - pairs who have never appeared together (anti-join via `NOT EXISTS`)
  - pairs born in the same year
  - pairs with identical movie sets (double `NOT EXISTS`)
- **Extremes / top performers**
  - actor(s) with the most movies overall
  - top movies by number of actors
  - actors/directors with most work in a time range (2000s, 2010–2020, etc.)
- **“For all” logic**
  - actors in every movie directed by a given director (e.g., Tarantino/Nolan) using nested `NOT EXISTS`
  - directors who never directed after a certain year
- **Conditional aggregation**
  - counts split by era (pre-2000 vs 2000+)
  - odd-year counts, percentages, and breakdowns

### Window functions (advanced)
- `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`
- `PARTITION BY` to compute per-actor/per-year/per-decade metrics without collapsing rows
- Running totals over time (filmography-to-date style queries)
- Ranking within partitions (top N per actor/year/decade)
- Notes on dialect differences (e.g., `QUALIFY` not supported in SQLite; use subquery filtering instead)

## Example problems solved

- “List all actors who co-starred with Kevin Bacon (born 1958), excluding Kevin Bacon.”
- “List unique actor pairs who have appeared together in at least 2/3 movies.”
- “Find actor pairs who have never acted together.”
- “Find actors who appear in every movie directed by Christopher Nolan.”
- “Top 2 most prolific actors per year (including ties).”
- “Top 3 actors per decade by number of appearances.”

## SQL dialect / compatibility

Most queries are written in a style compatible with SQLite/PostgreSQL.  
Where a feature is dialect-specific (e.g., `QUALIFY`), an alternative portable approach is included using a subquery.

## How to use

- Browse the `.sql` files to see each problem statement and its solution.
- Many queries include comments explaining the join paths and reasoning.
- Where multiple solutions exist, the repo often includes several approaches (e.g., `IN` vs `EXISTS` vs self-join) to reinforce patterns.

## Key takeaways / patterns I learned

- Use **self-joins** when comparing rows within the same table (co-stars, pairs).
- Use **`NOT EXISTS`** to express “missing” relationships cleanly (anti-joins).
- Use **double `NOT EXISTS`** for “same set” comparisons.
- Use **`HAVING`** for conditions on aggregates, and `WHERE` for raw row filters.
- Use **window functions** when you want group-aware calculations without losing row-level detail.
