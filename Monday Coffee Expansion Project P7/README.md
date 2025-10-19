# Monday Coffee Expansion SQL Project

![Company Logo](https://github.com/najirh/Monday-Coffee-Expansion-Project-P8/blob/main/1.png)

## Objective
The goal of this project is to analyze the sales data of Monday Coffee, a company that has been selling its products online since January 2023, and to recommend the top three major cities in India for opening new coffee shop locations based on consumer demand and sales performance.
## Table Creation
```
   CREATE TABLE city
   (
      city_id	INT PRIMARY KEY,
      city_name VARCHAR(15),	
      population	BIGINT,
      estimated_rent	FLOAT,
      city_rank INT
   );

   CREATE TABLE customers
   (
      customer_id INT PRIMARY KEY,	
      customer_name VARCHAR(25),	
      city_id INT,
      CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
   );


   CREATE TABLE products
   (
      product_id	INT PRIMARY KEY,
      product_name VARCHAR(35),	
      Price float
   );


   CREATE TABLE sales
   (
      sale_id	INT PRIMARY KEY,
      sale_date	date,
      product_id	INT,
      customer_id	INT,
      total FLOAT,
      rating INT,
      CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
      CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
   );
```

## Key Questions
1. **Coffee Consumers Count**  
   How many people in each city are estimated to consume coffee, given that 25% of the population does?
   ```
   SELECT city_name,
	   ROUND((population * 0.25)/1000000,2) AS Coffee_Consumer_in_Millions,
	   city_rank
   FROM city
   ORDER BY 2 DESC

   ```


2. **Total Revenue from Coffee Sales**  
   What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
```
SELECT 
    city_name,
	SUM(total) AS Total_revenue
FROM sales AS s
JOIN customers AS c
ON s.customer_id = c.customer_id
JOIN city AS ci
ON ci.city_id = c.city_id
WHERE EXTRACT(YEAR FROM sale_date) = 2023
AND EXTRACT(quarter FROM sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC 
```

3. **Sales Count for Each Product**  
   How many units of each coffee product have been sold?
```
   SELECT * FROM products
   SELECT * FROM sales

   SELECT p.product_name,
      COUNT(s.sale_id) AS Total_unit_sold 
      FROM products AS p
      LEFT JOIN sales AS s
      ON p.product_id = s.product_id
      GROUP BY 1
   ORDER BY 2 DESC
```

4. **Average Sales Amount per City**  
   What is the average sales amount per customer in each city?
```
   SELECT 
      ci.city_name,
      SUM(s.total) AS Total_Revenue,
      COUNT(DISTINCT s.customer_id) AS Total_Cutomer,
      ROUND(
      SUM(s.total)::numeric / COUNT( DISTINCT s.customer_id)::numeric,2) AS Average_sales_per_customer
   FROM sales AS s
   JOIN customers AS c
   ON s.customer_id = c.customer_id
   JOIN city AS ci
   ON ci.city_id = c.city_id
   GROUP BY 1
   ORDER BY 2
```

5. **City Population and Coffee Consumers**  
   Provide a list of cities along with their populations and estimated coffee consumers.
```
WITH city_table AS

(	SELECT 
	city_name,
	ROUND ((population * 0.25)/1000000,2) AS coffee_consumers 
	FROM city
), 
customers_table
AS
(
	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) AS unique_consumers
	FROM sales as s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city AS ci
	ON ci.city_id = c.city_id
	GROUP BY 1
)

SELECT 
	customers_table.city_name,
	city_table.coffee_consumers AS coffee_consumers_in_millions,
	customers_table.unique_consumers
FROM city_table 
JOIN customers_table 
ON city_table.city_name = customers_table.city_name    
```

6. **Top Selling Products by City**  
   What are the top 3 selling products in each city based on sales volume?
```
SELECT * 
FROM
(
	SELECT  
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) AS Total_Orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS city_rank
	FROM sales AS s
	JOIN products AS p
	ON s.product_id = p.product_id
	JOIN customers AS c
	ON c.customer_id = s.customer_id
	JOIN city AS ci
	ON c.city_id = ci.city_id
	GROUP BY 1,2
	-- ORDER BY 1,3 DESC - coz we take it into window fn 
) AS t1
WHERE city_rank <=3
```


7. **Customer Segmentation by City**  
   How many unique customers are there in each city who have purchased coffee products?
```
SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) AS Unique_Cutomer_Count
FROM city AS ci
LEFT JOIN customers AS c
ON ci.city_id = c.city_id
JOIN sales AS s 
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
GROUP BY 1

``` 

8. **Average Sale vs Rent**  
   Find each city and their average sale per customer and avg rent per customer
```
WITH city_table
AS
(	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) AS Total_Cutomer,
		ROUND(
		SUM(s.total)::numeric / COUNT( DISTINCT s.customer_id)::numeric,2) AS Average_sales_per_customer
	FROM sales AS s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city AS ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2
),
city_rent
AS
(SELECT city_name,
	   estimated_rent
FROM city
)
SELECT 	cr.city_name,
		cr.estimated_rent,
		ct.Total_Cutomer,
		ct.Average_sales_per_customer,
		ROUND
		(cr.estimated_rent::numeric / ct.Total_Cutomer::numeric, 2) AS Average_rent_per_customer  --avg rent per customer
FROM city_rent AS cr
JOIN city_table AS ct
ON ct.city_name = cr.city_name
ORDER BY 4 DESC
``` 

9. **Monthly Sales Growth**  
   Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
```

WITH Monthly_sales
AS 
(	
	SELECT 
		   ci.city_name,
	       EXTRACT(MONTH FROM sale_date) AS Month,
		   EXTRACT(YEAR FROM sale_date) AS Year,
		   SUM(s.total) AS Total_Sales
	FROM sales AS s
	JOIN customers AS c
	ON c.customer_id = s.customer_id
	JOIN city AS ci
	ON c.city_id = ci.city_id
	GROUP BY 1,2,3
	ORDER BY 1,3,2

),

Growth_ratio
AS
(
	SELECT  city_name,
			month,
			year, 
			Total_Sales AS curr_month_sales,
			LAG(Total_Sales, 1) OVER(PARTITION BY city_name ORDER BY year, month) AS last_month_sales	--LAG is new for me i ll read about it and learn it 
	FROM Monthly_sales	-- we make use of CTE's SUBQUERIS & WINDOW FUNTION 
)				-- coz of lag we get the null if there is no sales data is avilable in last month

SELECT 
		city_name,
		month,
		year, 
		curr_month_sales,
		last_month_sales,
		ROUND
			((curr_month_sales - last_month_sales)::numeric / last_month_sales ::numeric * 100 
		  	 , 2) AS Growth_ratio
			   
FROM Growth_ratio
WHERE Growth_ratio IS NOT NULL
``` 

10. **Market Potential Analysis**  
    Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated  coffee consumer
```

WITH city_table
AS
(	SELECT 
		ci.city_name,
		SUM(s.total) as total_revenue,
		COUNT(DISTINCT s.customer_id) AS Total_Cutomer,
		ROUND(
		SUM(s.total)::numeric / COUNT( DISTINCT s.customer_id)::numeric,2) AS Average_sales_per_customer
	FROM sales AS s
	JOIN customers AS c
	ON s.customer_id = c.customer_id
	JOIN city AS ci
	ON ci.city_id = c.city_id
	GROUP BY 1
	ORDER BY 2
),
city_rent
AS
(SELECT city_name,
	   estimated_rent,
	    ROUND ((population * 0.25) / 1000000, 2 ) AS estimated_coffee_consumers_in_millions
FROM city
)
SELECT 	cr.city_name,
		total_revenue,  -- from sales table total col as total_revenue
		cr.estimated_rent AS Total_Rent,
		ct.Total_Cutomer,
		estimated_coffee_consumers_in_millions,
		ct.Average_sales_per_customer,
		ROUND
		(cr.estimated_rent::numeric / ct.Total_Cutomer::numeric, 2) AS Average_rent_per_customer  
FROM city_rent AS cr
JOIN city_table AS ct
ON ct.city_name = cr.city_name
ORDER BY 2 DESC

``` 


## Recommendations
After analyzing the data, the recommended top three cities for new store openings are:

**City 1: Pune**  
1. Average rent per customer is very low.  
2. Highest total revenue.  
3. Average sales per customer is also high.

**City 2: Delhi**  
1. Highest estimated coffee consumers at 7.7 million.  
2. Highest total number of customers, which is 68.  
3. Average rent per customer is 330 (still under 500).

**City 3: Jaipur**  
1. Highest number of customers, which is 69.  
2. Average rent per customer is very low at 156.  
3. Average sales per customer is better at 11.6k.


## Thank You..!!