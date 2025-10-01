-- PROJECT_P4 - SPOTIFY 
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

							)

SELECT * FROM spotify;

-- Now EDA

SELECT  COUNT(DISTINCT Artist) FROM spotify;

SELECT  COUNT(DISTINCT Album) FROM spotify; 

SELECT DISTINCT Album_type FROM spotify;

SELECT MAX(Duration_min) FROM spotify;
SELECT MIN(Duration_min) FROM spotify;

SELECT Duration_min FROM spotify
WHERE Duration_min = 0;

DELETE FROM spotify
WHERE Duration_min = 0;	


SELECT Duration_min FROM spotify;

SELECT DISTINCT Channel  FROM spotify;

SELECT DISTINCT most_playedon  FROM spotify;


-- PROBLEM SOLVING 

-- 1.Retrieve the names of all tracks that have more than 1 billion streams.

SELECT  * FROM spotify
WHERE  Stream > 1000000000;


-- 2. List all albums along with their respective artists.

SELECT DISTINCT album,
       artist
FROM spotify
ORDER BY 1;

-- 3. Get the total number of comments for tracks where licensed = TRUE.
ALTER TABLE spotify
ALTER COLUMN Comments_song TYPE BIGINT
USING Comments_song::BIGINT;   -- i accidently write VARCHAR insted of BIGINT 


SELECT SUM(Comments_song) FROM spotify
WHERE licensed = 'true';


-- 4.Find all tracks that belong to the album type single.

SELECT track, Album_type FROM spotify
WHERE Album_type = 'single'


-- 5.Count the total number of tracks by each artist.

SELECT  * FROM spotify

SELECT artist,
 	COUNT (Track) AS total_tracks -- insted of COUNT(Track) we can use COUNT (*) a total_tracks
	FROM spotify
	GROUP BY 1
	ORDER BY 2 DESC;

	
-- 6. Calculate the average danceability of tracks in each album.

SELECT album_type, 
	   AVG(danceability) AS avg_danceability 
	   FROM spotify
	   WHERE album_type = 'album'
	   GROUP BY 1;
 

-- 7. Find the top 5 tracks with the highest energy values.

SELECT 
	Track,
	MAX(energy) AS highest_enegry_value_tracks
FROM spotify
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


--8. List all tracks along with their views and likes where official_video = TRUE.

SELECT Track,
	   SUM(Views_song) AS Total_Views,
	   SUM(likes) AS Total_Likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1
ORDER BY 2 DESC-- By default it is in ASEC
LIMIT 10  --TOP 10 because Dataset is huge and Records are more than 14,500+

SELECT * FROM spotify

--9 For each album, calculate the total views of all associated tracks.

SELECT album,
 	   Track,
	   SUM(Views_song) AS Total_Views 
FROM spotify
GROUP BY 1,2
ORDER BY 3 DESC;

--10 Retrieve the track names that have been streamed on Spotify more than YouTube.
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


-- BEFORE Using COALESCE we have many null values to we have to delete that wo make them 0 
-- i can not make use this COALESCE COl directly so i need to DO SUBQUERY 





-- Find the top 3 most-viewed tracks for each artist using window functions.

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


-- i did not understand the concept of dnese rank - WINDOW FUNCTION

-- Write a query to find tracks where the liveness score is above the average.

SELECT Track,
 	   Artist,
	   liveness
	   FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify) -- make use of subquery incase infuture if any values has been change so we dont need to write query at that time

-- Use a WITH clause to calculate the difference between the highest and lowest 
--energy values for tracks in each album.


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


--Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT DISTINCT  
		Track,
		Energy,
		Liveness,
		(energy / liveness) AS ratio
FROM spotify
WHERE (energy / liveness > 1.2) 


--Calculate the cumulative sum of likes for tracks 
--ordered by the number of views, using window functions.



SELECT 	
		Track,
		Views_song,
		Likes,
		SUM(likes) OVER( ORDER BY Views_Song DESC) AS Cumulative_Sum
FROM spotify;

SELECT * FROM spotify


--		Query Optimization
EXPLAIN ANALYZE
SELECT
	artist,
	track,
	views_song
FROM spotify
WHERE artist ='Gorillaz'
AND
most_playedon = 'Youtube'
ORDER BY Stream DESC LIMIT 30

DROP index artist_index
CREATE INDEX artist_index ON spotify (artist);

