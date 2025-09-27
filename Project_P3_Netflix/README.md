# Netflix Movies and TV Shows Data Analysis using SQL
![Logo](https://github.com/ashwin-pawar/SQL-Practice-Projects/blob/main/Project_P3_Netflix/logo.png)


## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
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
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
type_m,
COUNT(*) as Total_numbers
FROM netflix_data
GROUP BY 1;
```


### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT 
	type_m,
	rating
FROM 
(
SELECT 
	type_m,
	rating,
	COUNT (*),
	RANK () OVER ( PARTITION BY type_m ORDER BY COUNT(*) DESC) AS ranking 
FROM netflix_data
GROUP BY 1, 2
) as tbl1 
WHERE ranking = 1;
```


### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * FROM netflix_data
WHERE 
	  type_m = 'Movie'
	  AND
	  release_year = 2020;
```


### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
UNNEST (STRING_TO_ARRAY(country, ',')) AS new_country,
COUNT (show_id) as total_content
FROM netflix_data
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5 ; 
```


### 5. Identify the Longest Movie

```sql
SELECT * FROM netflix_data
WHERE 
	type_m = 'Movie'
	AND
	duration = (SELECT MAX(duration)FROM netflix_data)
```


### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
	*
	FROM netflix_data  
	WHERE
	TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '6 years'
```


### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * FROM netflix_data
WHERE director ILIKE '%Rajiv Chilaka%'
```


### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT * FROM netflix_data
WHERE 
	type_m = 'TV Show' 
	AND
	SPLIT_PART(duration,' ',1) ::numeric >5
```


### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 	
		UNNEST (STRING_TO_ARRAY(listed_in, ',')) AS Genre,
		COUNT(show_id) AS Total_Content
FROM netflix_data
GROUP BY 1

SELECT * FROM netflix_data
```


### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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

```


### 11. List All Movies that are Documentaries

```sql
SELECT * FROM netflix_data
WHERE listed_in ILIKE '%documentaries%'
```


### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix_data
WHERE director IS NOT NULL 
```


### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * FROM netflix_data
WHERE cast_name ILIKE '%Salman khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 20
```


### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
--listed_in,
--cast_name,
UNNEST(STRING_TO_ARRAY(cast_name,',')) AS Actors,
COUNT(*) AS Total_Content
FROM netflix_data
WHERE country ILIKE '%India%'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10
```

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
WITH new_table 
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
```

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.




