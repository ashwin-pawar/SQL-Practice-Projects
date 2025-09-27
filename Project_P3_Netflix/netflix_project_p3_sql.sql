-- Netflix Project P3

DROP TABLE IF EXISTS netflix_data
CREATE TABLE netflix_data (
				Show_id	VARCHAR(10),
				Type_m 	VARCHAR(10),
				Title	VARCHAR(160),
				Director VARCHAR(220),
				Cast_name VARCHAR(780),
				Country	 VARCHAR(150),
				Date_added VARCHAR(50),
				Release_year INT,
				Rating	 VARCHAR(140),
				Duration VARCHAR(150),
				Listed_in VARCHAR(100),
				Description VARCHAR(250)
		     );

SELECT * FROM netflix_data;


-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT 
type_m,
COUNT(*) as Total_numbers
FROM netflix_data
GROUP BY 1; --OR type_m
)

-- 2. Find the most common rating for movies and TV shows
	-- in rating there is no number or chareccter like good bad etc so we can't use max funtion
SELECT 
	type_m,
	rating
FROM 
(
SELECT 
	type_m,
	rating,
	COUNT (*),
	RANK () OVER ( PARTITION BY type_m ORDER BY COUNT(*) DESC ) AS ranking  --window fn
FROM netflix_data
GROUP BY 1, 2
) as tbl1 
WHERE ranking = 1;


--27/09/2025

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix_data
WHERE 
	  type_m = 'Movie'
	  AND
	  release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
UNNEST (STRING_TO_ARRAY(country, ',')) AS new_country, -- UNNEST is used for seperating the word by delimeter From many words in col.
COUNT (show_id) as total_content
FROM netflix_data
GROUP BY 1
ORDER BY 2 DESC -- Order by total_content
LIMIT 5 ; -- TOP 5 COUNTRY



-- 5. Identify the longest movie

SELECT * FROM netflix_data
-- Text + Number hai toh convert 1st 
WHERE 
	type_m = 'Movie'
	AND
	duration = (SELECT MAX(duration)FROM netflix_data)



-- 6. Find content added in the last 5 years

SELECT 
	*
	FROM netflix_data   -- TO_DATE -new for me, SEPTEMBER 25 2021 - Month(month name STRING) DD YYYY 
	WHERE
	TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '6 years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix_data
WHERE director ILIKE '%Rajiv Chilaka%' -- One emovie or tv show can have multiple director
               					       -- so WE CAN  use LIKE insted of = jaha jaha name hoga waha k row select ho jayega 


-- 8. List all TV shows with more than 5 seasons

SELECT * FROM netflix_data
WHERE 
	type_m = 'TV Show' 
	AND
	SPLIT_PART(duration,' ',1) ::numeric >5  -- numeric coz sql dont know the datatype of SPLIT_PART



--9. Count the number of content items in each genre

SELECT * FROM netflix_data


SELECT 	
		UNNEST (STRING_TO_ARRAY(listed_in, ',')) AS Genre,
		COUNT(show_id) AS Total_Content
FROM netflix_data
GROUP BY 1
		
-- UNNEST AND STRING_TO_ARRAY - function is used for seperating genres and split them 

-- 10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!

SELECT * FROM netflix_data


SELECT
		EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS Year,
		COUNT(*) AS Year_Content,
		ROUND 
		(COUNT(*) ::numeric/
		(SELECT COUNT(*) FROM netflix_data WHERE country ='India')::numeric * 100 , 2 
		) AS avg_content_per_year
FROM netflix_data
WHERE country ='India'
GROUP BY 1 -- write Spelling correctly
ORDER BY avg_content_per_year DESC 
LIMIT 5;



-- 11. List all movies that are documentaries

SELECT * FROM netflix_data
WHERE listed_in ILIKE '%documentaries%'



-- 12. Find all content without a director

SELECT * FROM netflix_data
WHERE director IS NOT NULL 


-- 13. Find how many movies actor 'Salman Khan' appeared in last 20 years!

SELECT * FROM netflix_data
WHERE cast_name ILIKE '%Salman khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 20



--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
--listed_in,
--cast_name,
UNNEST(STRING_TO_ARRAY(cast_name,',')) AS Actors, -- STRING TO ARRAY for seperate word by delimeter and unnest for printing each actors name in row
COUNT(*) AS Total_Content
FROM netflix_data
WHERE country ILIKE '%India%'
GROUP BY 1 
ORDER BY 2 DESC  -- 2 Total_Content
LIMIT 10

/* 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
	the description field. Label content containing these keywords as 'Bad' and all other 
	content as 'Good'. Count how many items fall into each category.
	*/ 


WITH new_table -- we wants to do group by category so that i can do count 
AS (
SELECT 
		*,
		CASE
		WHEN
		   description ILIKE '%kill%'
		   OR
		   description ILIKE '%violence%'
		THEN 'Bad_Content' 
		ELSE 'Good_Content'
		END category 
FROM netflix_data			
) 

SELECT
      category,
	  COUNT(*) AS Total_Content	
FROM new_table
GROUP BY 1;

		
SELECT *  FROM netflix_data
WHERE 
	description ILIKE '%kill%'
	OR
	description ILIKE '%violence%'




