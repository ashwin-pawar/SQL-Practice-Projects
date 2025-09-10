CREATE DATABASE Project_P1; 

CREATE TABLE retail_sales_tb
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(20),
    age INT,
    category VARCHAR(20),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

SELECT * FROM retail_sales_tb
LIMIT 10

SELECT 
	COUNT (*)
FROM retail_sales_tb -- how many row and col we have in total - 1987 / 2000


-- Data Cleaning ( Manually one by one for all Col)

SELECT 	* FROM retail_sales_tb
WHERE transactions_id IS NULL  -- checking if there is any null vaules
	
SELECT * FROM retail_sales_tb
WHERE sale_date IS NULL 

SELECT * FROM retail_sales_tb
WHERE sale_time IS NULL           -- insted of doing this way i can used smart way 

-- Smart Way

SELECT * FROM retail_sales_tb
WHERE 
      transactions_id IS NULL 
	  OR
	  sale_date IS NULL 
	  OR
	  sale_time IS NULL
	  OR
	  customer_id IS NULL  
	  OR
	  gender IS NULL
	  OR
	  age IS NULL
	  OR 
	  category IS NULL
	  OR
	  quantity IS NULL
	  OR
	  price_per_unit IS NULL 
	  OR
	  cogs IS NULL 
	  OR
	  total_sale IS NULL; -- End SQL statement with a semicolon (;)


	  
DELETE 	FROM retail_sales_tb 
WHERE 
      transactions_id IS NULL   --Deleting records that contain null values 
	  OR
	  sale_date IS NULL 
	  OR
	  sale_time IS NULL
	  OR
	  customer_id IS NULL
	  OR
	  gender IS NULL    
	  OR
	  age IS NULL
	  OR 
	  category IS NULL
	  OR
	  quantity IS NULL
	  OR
	  price_per_unit IS NULL 
	  OR
	  cogs IS NULL 
	  OR
	  total_sale IS NULL;




-- Data Exploration 

-- How many sales/record we have?

SELECT 
	COUNT (*) as total_sale
FROM retail_sales_tb  -- 1987

-- How many uniquie cutomer we have ?

SELECT COUNT( DISTINCT customer_id)
as total_sale
FROM retail_sales_tb   -- 155

-- How many unique category we have 

SELECT DISTINCT category FROM retail_sales_tb   --DISTINCT - Unique values
SELECT COUNT( DISTINCT category)               --  COUNT is used to know numbers 
as total_sale                                   
FROM retail_sales_tb  


-- DATA Analysis and Business Key Problems and Answer

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT * FROM retail_sales_tb  
WHERE sale_date = '2022-11-05' 


-- Q. 2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 1O in the month of Nov—2022

SELECT * FROM retail_sales_tb
WHERE category = 'Clothing' 
AND 
TO_CHAR( sale_date, 'YYYY-MM') = '2022-11'
AND
quantity >= 4;              

--Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category,
	SUM( total_sale ) as Net_Sale,  -- Don’t forget to add a comma when selecting two or more column names
	COUNT (*) as total_orders      
FROM retail_sales_tb
GROUP BY 1;                      -- Use category name directly in MySQL queries, e.g., 'Beauty'

-- Q. 4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT 
ROUND(AVG(age) , 2 ) 	 -- ROUND - This function is used to shorten the length of numbers after decimal points
AS Avg_age 					
FROM retail_sales_tb
WHERE category = 'Beauty' 

-- Q. 5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales_tb
WHERE total_sale >= 1000 AND quantity >= 3;         -- GROUP BY is always used with aggregate functions like SUM, AVG, etc.

-- Q. 6 Write a SQL query to find the totat number of transactions (transaction_id) made by each gender in each category.

SELECT category,
       gender,
	   COUNT(*) as Total_Trans    -- Grouping by category to calculate total transactions


	   											
FROM retail_sales_tb
 GROUP BY 
 category,       -- grouping of both category
 gender 
 ORDER BY 1 --ORDER BY 1 → Sorts results by the first column in the SELECT list


-- Q. 7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT 
    year,
	month,
average_sales FROM ( 
SELECT                  
  EXTRACT (YEAR FROM sale_date) as Year ,  -- We don’t have separate month and year columns, so we extract them from sale_date
  EXTRACT (MONTH FROM sale_date) as Month ,
  AVG(total_sale) as  average_sales, 
	
 RANK() OVER( PARTITION BY EXTRACT(YEAR FROM sale_date)  --  New for me
 ORDER BY AVG(total_sale)  DESC) as Rank

 FROM retail_sales_tb
 GROUP BY 1,2  -- -- GROUP BY 1,2 groups the results by the first and second selected columns 
 ) as t1
 WHERE Rank = 1    -- This Q is New and little bit Confusiong and hard to understand and solve for me as of now 

 

-- Q. 8 Write a SQL query to find the top 5 customers based on the highest total sales

SELECT 
     customer_id,
	 SUM(total_sale)  as Total_Sales
FROM retail_sales_tb
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5                          

-- Q. 9 Write a SQL query to find the number of unique customers who purchased items from each category.


SELECT category,
COUNT ( DISTINCT customer_id) as Unique_customers
FROM retail_sales_tb
GROUP BY category 

-- Q.1O Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening > 17


WITH hourely_sale                     -- This Q is Hard but Intresting i learn something new 
AS
(
SELECT *,
	CASE 
		WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'                           -- Extracting Time (Hours) from sale_time col 
		WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
     END as Shift                     -
	 FROM retail_sales_tb
)
SELECT Shift,
COUNT (*) as Total_Orders
FROM hourely_Sale
GROUP BY Shift 


--                           END OF PROJECT P1     
