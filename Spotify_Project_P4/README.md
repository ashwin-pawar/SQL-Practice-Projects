# Spotify Advanced SQL Project and Query Optimization P4


![Spotify Logo](https://github.com/ashwin-pawar/SQL-Practice-Projects/blob/main/Spotify_Project_P4/spotify_logo.jpg)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- create table
DROP TABLE IF EXISTS spotify
CREATE TABLE spotify (
				Artist  VARCHAR(255),
				Track	VARCHAR(255),
				Album	VARCHAR(255),
				Album_type	VARCHAR(55),
				Danceability   FLOAT,
				Energy		   FLOAT,
				Loudness	   FLOAT,
				Speechiness	   FLOAT,
				Acousticness   FLOAT,
				Instrumentalness FLOAT,
				Liveness	   FLOAT,
				Valence  	   FLOAT,
				Tempo  		   FLOAT,
				Duration_min   FLOAT,
				Title	VARCHAR(255),
				Channel	VARCHAR(255),
				Views_song	BIGINT,
				Likes  	    BIGINT,
				Comments_song	VARCHAR(255),
				Licensed	BOOLEAN,
				official_video	BOOLEAN,
				Stream	    BIGINT,
				EnergyLiveness	FLOAT,
				most_playedon  VARCHAR(50)
				     );
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 4. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 5. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

### Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT  * FROM spotify
WHERE  Stream > 1000000000;
```
2. List all albums along with their respective artists.
```sql
 SELECT DISTINCT
	 album,
	 artist
FROM spotify
ORDER BY 1;
```

3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql
SELECT SUM(Comments_song) FROM spotify
WHERE licensed = 'true';
```

4. Find all tracks that belong to the album type `single`.
```sql

SELECT track, Album_type FROM spotify
WHERE Album_type = 'single'
```
5. Count the total number of tracks by each artist.
```sql
SELECT  * FROM spotify

SELECT artist,
 	COUNT (Track) AS total_tracks
	FROM spotify
	GROUP BY 1
	ORDER BY 2 DESC;
```
### Medium Level

1. Calculate the average danceability of tracks in each album.
```sql

SELECT album_type, 
	   AVG(danceability) AS avg_danceability 
	   FROM spotify
	   WHERE album_type = 'album'
	   GROUP BY 1;

```

2. Find the top 5 tracks with the highest energy values.
```sql
SELECT 
	Track,
	MAX(energy) AS highest_enegry_value_tracks
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

```

3. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
SELECT Track,
	   SUM(Views_song) AS Total_Views,
	   SUM(likes) AS Total_Likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10  

SELECT * FROM spotify
```

4. For each album, calculate the total views of all associated tracks.
```sql

SELECT album,
 	   Track,
	   SUM(Views_song) AS Total_Views 
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;
```

5. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
SELECT * FROM 
(
SELECT Track,
	  -- Stream,
	   COALESCE(SUM (CASE WHEN most_playedon = 'Youtube' THEN Stream END),0) AS Stream_on_Youtube,
	   COALESCE(SUM (CASE WHEN most_playedon = 'Spotify' THEN Stream END),0) AS Stream_on_Spotify
FROM spotify
GROUP BY 1

) t1

	WHERE  Stream_on_Spotify > Stream_on_Youtube
	AND Stream_on_Youtube <> 0
```

### Advanced Level

1. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
WITH ranking_artist 
AS
(
SELECT 
		
		Artist,
		Track,
		SUM(Views_song) AS Total_Views,
		DENSE_RANK() OVER (PARTITION BY Artist ORDER BY SUM(Views_song) DESC ) as rank

FROM spotify
GROUP BY 1,2
ORDER BY 2,3 DESC
)

SELECT * FROM ranking_artist
WHERE rank <= 3

```

2. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT Track,
 	   Artist,
	   liveness
	   FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify) 

```

3. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
SELECT  * FROM spotify

WITH cte
AS(
SELECT  
		album,
		MAX(energy) AS highest_Energy,
		MIN(energy) AS lowest_Energy
FROM spotify
GROUP BY 1
) 

SELECT album,
	   highest_Energy - lowest_Energy AS Difference_between_energy
FROM cte
ORDER BY 2 DESC
```
   
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
SELECT DISTINCT  
		Track,
		Energy,
		Liveness,
		(energy / liveness) AS ratio
FROM spotify
WHERE (energy / liveness > 1.2) 
```

5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
SELECT 	
		Track,
		Views_song,
		Likes,
		SUM(likes) OVER( ORDER BY Views_Song DESC) AS Cumulative_Sum
FROM spotify;

SELECT * FROM spotify
```
---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **5.7 ms**
        - Planning time (P.T.): **0.70 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX artist_index ON spotify (artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.13 ms**
        - Planning time (P.T.): **2.05 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/ashwin-pawar/SQL-Practice-Projects/blob/main/Spotify_Project_P4/After%20%20Query%20Optimization.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/ashwin-pawar/SQL-Practice-Projects/blob/main/Spotify_Project_P4/Screenshot%202025-10-01%20120227.png)
      ![Performance Graph](https://github.com/ashwin-pawar/SQL-Practice-Projects/blob/main/Spotify_Project_P4/before.png)
      ![Performance Graph](https://github.com/ashwin-pawar/SQL-Practice-Projects/blob/main/Spotify_Project_P4/Screenshot%202025-10-01%20120055.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation)

---

## Next Steps
- **Visualize the Data**: Use a data visualization tool like **Tableau** or **Power BI** to create dashboards based on the query results.
- **Expand Dataset**: Add more rows to the dataset for broader analysis and scalability testing.
- **Advanced Querying**: Dive deeper into query optimization and explore the performance of SQL queries on larger datasets.

---

