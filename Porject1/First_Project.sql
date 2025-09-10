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


-- Data Cleaning

SELECT 	* FROM retail_sales_tb
WHERE transactions_id IS NULL -- expalin - table k andar jitni bhi rows hai es particular col k andr 
                              -- sari ki sari null values show karega we dont have so nhi show kia
SELECT * FROM retail_sales_tb
WHERE sale_date IS NULL 

SELECT * FROM retail_sales_tb
WHERE sale_time IS NULL   ------ insted of doing this way we can use smart way 

--- SMart Way

SELECT * FROM retail_sales_tb
WHERE 
      transactions_id IS NULL 
	  OR
	  sale_date IS NULL 
	  OR
	  sale_time IS NULL
	  OR
	  customer_id IS NULL  --  hm dekh rhe hai kaha kaha null values hai jaha h wo col and row dikh jayega
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
	  total_sale IS NULL; --  end me ; lagadena chaiye lekin () ho toh ); yaha lagana hai na ki last line me



	  
DELETE 	FROM retail_sales_tb
WHERE 
      transactions_id IS NULL 
	  OR
	  sale_date IS NULL 
	  OR
	  sale_time IS NULL
	  OR
	  customer_id IS NULL
	  OR
	  gender IS NULL    -- hm un sbki row jaha null values hai wo delete krne wale hai 
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

-- how many sales/record we have?

SELECT 
	COUNT (*) as total_sale
FROM retail_sales_tb  -- 1987

-- how many uniquie cutomer we have ?

SELECT COUNT( DISTINCT customer_id)
as total_sale
FROM retail_sales_tb   -- 155

-- How many unique category we have 

SELECT DISTINCT category FROM retail_sales_tb   --  CATEGORY NAMES k liye hai 

SELECT COUNT( DISTINCT category)
as total_sale                                    --  to know numbers 
FROM retail_sales_tb  


-- DATA Analysis and Business Key Problems and ans 

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT * FROM retail_sales_tb   -- *  for all records
WHERE sale_date = '2022-11-05'  --  For exact no - COUNT (sale_date) as total_sale       --11


-- Q. 2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 1O in the month of Nov—2022

SELECT * FROM retail_sales_tb
WHERE category = 'Clothing' 
AND 
TO_CHAR( sale_date, 'YYYY-MM') = '2022-11'
AND
quantity >= 4;                       -- 17



--Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category,
	SUM( total_sale ) as Net_Sale,      -- comma dena 2 col name likhe the aur as k bad jo marzi likho 
	COUNT (*) as total_orders -- extra to know total orders
FROM retail_sales_tb
GROUP BY 1; --  MYSQL me by Category Name i.e Beauty


-- Q. 4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT 
ROUND(AVG(age) , 2 ) -- ->40.42		 	 -- * kia toh jaha ki category beauty hai waha ka sara table me info dikh jayega
 AS Avg_age 					-- 40.415711947626 bht bada hai length so round funtion we use 
FROM retail_sales_tb
WHERE category = 'Beauty'   -- Only age likha to all age


-- Q. 5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales_tb
WHERE total_sale >= 1000 AND quantity >= 3;
-- GROUP bY is always used with aggregate functions like SUM AVG etc

-- Q. 6 Write a SQL query to find the totat number of transactions (transaction_id) made by each gender in each category.

SELECT category,
       gender,
	   COUNT( * ) as Total_Trans    -- we have to find total transtions so thats why we group both catergory 
	   											
FROM retail_sales_tb

GROUP BY 
 category,      --  grouping of both category
 gender 
Order by 1 -- ; ye last me lagao ya nahi fark nhi pdta
			-- order by 1 mtlb 1st col a - z order lagega 


-- Q. 7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT 
    year,
	month,
average_sales FROM ( 

SELECT                    --  we dont have moth and year col so we hv to extract that form col i.e sale_date
  EXTRACT (YEAR FROM sale_date) as Year ,
  EXTRACT (MONTH FROM sale_date) as Month ,
  AVG(total_sale) as  average_sales,

--  New thing for me

 RANK() OVER( PARTITION BY EXTRACT(YEAR FROM sale_date)
 ORDER BY AVG(total_sale)  DESC) as Rank

 FROM retail_sales_tb
 GROUP BY 1,2  --  MONTH AND YEAR  hai so wo ana hi chaiye Group by me else it shows error 
 

) as t1

WHERE Rank = 1 

-- Confusining and little bit new and hard tha for me as of now 

-- Q. 8 Write a SQL query to find the top 5 customers based on the highest total sales

SELECT 
     customer_id,
	 SUM(total_sale)  as Total_Sales
FROM retail_sales_tb
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5                           -- EASY but i had doubt 


-- Q. 9 Write a SQL query to find the number of unique customers who purchased items from each category.


SELECT category,
COUNT ( DISTINCT customer_id) as Unique_customers
FROM retail_sales_tb
GROUP BY category 

-- Q.1O Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening > 17


WITH hourely_sale                     -- hard hai thoda but new sikhne ko mila like with, when , else then, end etc
AS
(
SELECT *,
	CASE 
		WHEN EXTRACT (HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
     END as Shift                     -- working fine with whole data we just reated new col using sale_time col
	 FROM retail_sales_tb

)
SELECT Shift,
COUNT (*) as Total_Orders
FROM hourely_Sale
GROUP BY Shift


--                           END OF PROJECT P1        subh se kr rha hu 1:47 ho gye thaks god 