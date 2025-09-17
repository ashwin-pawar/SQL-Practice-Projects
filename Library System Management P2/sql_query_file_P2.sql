CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10)
);


CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10)
            
);

DROP TABLE IF EXISTS return_status;

CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
			FOREIGN KEY (return_book_isbn) REFERENCES books(isbn) 
			-- there is some problem occurs while importing data 
			-- so i changes the way to import data and import in
            
);

select * from return_status
INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS101', 'IS101', '2023-06-06'),
('RS102', 'IS105', '2023-06-07'),
('RS103', 'IS103', '2023-08-07'),
('RS104', 'IS106', '2024-05-01'),
('RS105', 'IS107', '2024-05-03'),
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');


SELECT * FROM issued_status;




ALTER TABLE employees 
ADD CONSTRAINT fk_employees
FOREIGN KEY( branch_id )
REFERENCES branch(branch_id)

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_member_id)
REFERENCES members (member_id)


ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_stas
FOREIGN KEY (issued_emp_id)
REFERENCES employees (emp_id)


ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_isbn
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn)


-- ALTER TABLE return_status
-- ADD CONSTRAINT fk_return_book_isbn
-- FOREIGN KEY (issued_id)
-- REFERENCES issued_status(issued_id)


SELECT * from books;
SELECT * from branch;
SELECT * from employees;
SELECT * from issued_status;
SELECT * from members;
SELECT * from return_status;



-- Solving Tasks / Problems

                                  -- CRUD OPERATIONS -- 

-- Task 1. Create a New Book Record 
-- '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '510 MG road'
WHERE member_id = 'C104';
SELECT * from members


--Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121'
SELECT * from issued_status;    -- DELETE FROM the from i was missing i need to go through syntax of sql queries

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

--List 5: Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id
--COUNT(issued_id) as total_books_issued      
FROM issued_status
GROUP BY 1 
HAVING COUNT(issued_id) >1;

--  CTAS (Create Table As Select)
--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE issued_books_count
AS 
SELECT b.book_title,
       b.isbn,
	   b.category,
	   COUNT(ist.issued_id) AS total_books_counts
FROM books AS b
JOIN 
issued_status AS ist                                              -- Created table after writing query
ON ist.issued_book_isbn = b.isbn
GROUP BY 1,2


SELECT * FROM issued_status
SELECT * FROM issued_books_count


--Task:7 Retrive All the Books in Specific Category 

SELECT * FROM books
WHERE category = 'Classic'


--Task 8: Fint Total Rental Income by Category;

SELECT b.category,
       SUM(b.rental_price), 
	   COUNT(*)               -- Shows how many books issued 
FROM books as b
JOIN issued_status as ist
ON b.isbn = ist.issued_book_isbn
GROUP BY 1


--Task 9:List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 Days'  -- INTERVAL - we can sepcify thet time (month,days,years)

INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES('C220', 'Martin Deo', 'ST Fanc', '2025-06-11')
      ('C221', 'Tanjiro sa', 'ST Lan', '2025-07-21')
	  ('C222', 'Inosuke GS', 'ST San', '2025-07-11')

--Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT b.*,
       emp.emp_id,
	   emp.emp_name,
	   emp.position,
	   emp.salary,
	   emp2.emp_name as Manager              
-- We joined the employees table twice: 1st join: to link employees with their branch (branch_id).
-- 2nd join: to get the branch manager's details (manager_id).

FROM 
employees as emp
JOIN 
branch as b
ON emp.branch_id = b.branch_id
JOIN 
employees as emp2
ON emp.emp_id = b.manager_id


--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:


CREATE TABLE Books_rental_price
AS
SELECT * FROM books
WHERE rental_price >= 5

SELECT * FROM Books_rental_price

DROP TABLE Books_rental_price


--Task 12: Retrieve the List of Books Not Yet Returned


SELECT * FROM issued_status AS ist
LEFT JOIN return_status AS rtns
ON ist.issued_id = rtns.issued_id
WHERE rtns.return_id IS NULL -- If return_id is NULL, it means the book has not been returned yet.

SELECT * FROM return_status


--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period).
--Display the member's_id, member's name, book title, issue date, and days overdue.


-- issued _ status -— members -= books —- return _ status
-- filter books which is return
-- overdue > 30


SELECT * from books;
SELECT * from branch;
SELECT * from employees;
SELECT * from issued_status;
SELECT * from members;
SELECT * from return_status;


SELECT mbrs.member_id,
       mbrs.member_name,
	   bk.book_title,
	   ist.issued_date,
	  -- rtns.return_date,

CURRENT_DATE - ist.issued_date AS Over_due_date

FROM issued_status AS ist 
JOIN members AS mbrs
ON ist.issued_member_id = mbrs.member_id
JOIN books AS bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS  rtns
ON rtns.issued_id = ist.issued_id

WHERE rtns.return_date IS NULL -- return date = no overdues
AND 
CURRENT_DATE - (ist.issued_date) > 30  -- days below 30 has no overdues 

ORDER BY 1


-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

CREATE OR REPLACE PROCEDURE Update_book_status 
(p_return_id VARCHAR(20), p_issued_id VARCHAR(20), p_book_quality VARCHAR(20))
-- CREATE & INPUT PARAMETER'S which is enter by user/employee

LANGUAGE plpgsql
AS $$                     

DECLARE   -- Declared Local variables

v_book_isbn VARCHAR(70);   
v_book_name VARCHAR(70);

BEGIN   -- all code and logic begin from here 

INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
VALUES(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality );

SELECT 
issued_book_isbn,
issued_book_name   -- select both rows


INTO
v_book_isbn,    -- insert there values into local varibale
v_book_name

FROM issued_status
WHERE issued_id = p_issued_id; 


UPDATE books                    --updating books status to YES when both books isbn is same 
SET status ='yes'
WHERE isbn  = v_book_isbn;

RAISE NOTICE 'Thank You For Returning Book : %' , v_book_name;   -- Display Messsage 

END; 
$$;        -- it shows the end of procedure

-- My first Procedure is created successfully 

-- Testing Functions 
SELECT * from books
-- WHERE isbn ='978-0-7432-7357-1'
WHERE isbn = '978-0-375-41398-8'



SELECT * from issued_status  
WHERE issued_book_name = 'The Diary of a Young Girl'  --IS134

WHERE issued_book_isbn = '978-0-7432-7357-1'  --IS136

SELECT * from return_status
WHERE return_book_isbn ='978-0-375-41398-8' 



WHERE return_id = 'RS149'
WHERE return_book_isbn = '978-0-7432-7357-1'  -- not return yet

-- Calling Procedure


CALL Update_book_status('RS149', 'IS136', 'Bad');
CALL Update_book_status('RS148', 'IS140', 'Good');
CALL Update_book_status('RS150', 'IS134', 'Damaged'); -- status changed




-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch,showing the number of books issued, 
-- the number of books returned, and the total revenue generated from book rentals.


SELECT * from books;
SELECT * from branch;
SELECT * from employees;
SELECT * from issued_status;
SELECT * from members;
SELECT * from return_status;

CREATE TABLE Branch_Report
AS
SELECT 
	b.branch_id,
	b.manager_id,
	SUM(bk.rental_price) AS total_revenue_generated,
	COUNT(rs.return_id) AS total_books_returned,
	COUNT(ist.issued_id) AS total_books_issued

FROM issued_status as ist
JOIN employees as e
ON e.emp_id = ist.issued_emp_id
JOIN branch as b 
ON e.branch_id = b.branch_id
LEFT JOIN return_status as rs
ON rs.issued_id = ist.issued_id   -- i'm getting problem in Selecting which row i have to select from which table to join ughhh
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn -- Done all Joins 
GROUP BY 1, 2


SELECT * from Branch_Report;

-- NOTE - Understand which columns we are using to join the tables and there sequence also (,) 

-- Task 16: CTAS: Create a Table of Active Members
-- CREATE TABLE AS (CTAS) statement to create a
-- new table active_members containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_members 
AS
SELECT * FROM members
WHERE member_id IN (

SELECT DISTINCT issued_member_id
FROM issued_status
WHERE issued_date >= CURRENT_DATE - INTERVAL '2 Month'    

)
SELECT * FROM active_members;     ---Here i used SUBQUERY and CTS's + JOINS

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues.
-- Display the employee name, number of books processed, and their branch.

SELECT emp.emp_name,
	   b.*,
       COUNT(ist.issued_book_isbn) as total_books_issued
	   

FROM issued_status as ist
JOIN employees as emp 
ON ist.issued_emp_id = emp.emp_id
JOIN branch as b
ON emp.branch_id = b.branch_id
GROUP BY 1,2

/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged"
in the books table. 
Display the member name, book title, and the number of times they've issued damaged books.*/

SELECT  * FROM books;
SELECT  * FROM issued_status;
SELECT * from branch;
SELECT * from employees;
SELECT * from members;
SELECT * from return_status;

SELECT rs.book_quality, 
COUNT(*) 
FROM return_status rs
GROUP BY rs.book_quality;


SELECT 
		m.member_name,
	    ist.issued_book_name,
		COUNT (rs.book_quality) AS Damaged_books
		
FROM issued_status as ist 
JOIN members as m
ON ist.issued_member_id = m.member_id
JOIN return_status as rs
ON ist.issued_id = rs.issued_id 
WHERE rs.book_quality ='Damaged'
GROUP BY 1,2
-- HAVING COUNT(*)> 2  -- No rows returned because no member has damaged the same book multiple times.
                       -- We can insert some sample data and then perform this operation to test the query.


/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available,
it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'),
the procedure should return an error message indicating thatthe book is currently not available.*/

SELECT  * FROM books;
SELECT  * FROM issued_status;


CREATE OR REPLACE PROCEDURE Update_books_status 
(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(20), p_issued_emp_id VARCHAR(20))

LANGUAGE plpgsql
AS $$

DECLARE 

v_status VARCHAR(10);  --lcoal variable _v_status

BEGIN  -- LOGIC AND CODE

SELECT status 
INTO
v_status
FROM books 
WHERE isbn = p_issued_book_isbn;     -- checking book status is available or not 

IF v_status = 'yes' THEN 
    INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
	VALUES(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

	UPDATE books
	SET status ='no'
	WHERE isbn = p_issued_book_isbn;

	RAISE NOTICE 'The books is Available, Record added Successfully Book_isbn: %', p_issued_book_isbn;

ELSE 
    RAISE NOTICE 'Sorry Book is Not Available This Time %', p_issued_book_isbn;
	
END IF;   -- syntax - IF Condition THEN ELSE END IF 

END 
$$;




SELECT  * FROM books;
-- 978-0-553-29698-2 -- yes
-- 978-0-307-58837-1 -- no 

CALL Update_books_status('IS155', 'C104', '978-0-553-29698-2', 'E104');  -- no

SELECT  * FROM books
WHERE isbn = '978-0-553-29698-2';

CALL Update_books_status('IS156', 'C105', '978-0-307-58837-1', 'E108');  
CALL Update_books_status('IS157', 'C104', '978-0-525-47535-5', 'E105'); 





/*Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days.
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50.
The number of books issued by each member.
The resulting table should show: Member ID, Number of overdue books and Total fines*/

 --- members - issued-status - return status
SELECT issued_member_id,
	   COUNT(*) AS Number_of_overdues_books,
	   SUM(fine_amount) AS Total_Fine
FROM (
  SELECT
 	   ist.issued_member_id,
	   ist.issued_book_name,
       ist.issued_date,
	   ist.issued_book_isbn,
	   CURRENT_DATE - ist.issued_date AS issued_Days,
  GREATEST((CURRENT_DATE - ist.issued_date)- 30, 0) AS Overdues_Days,
  GREATEST((CURRENT_DATE - ist.issued_date)- 30, 0) * 0.50 AS fine_amount

 FROM issued_status as ist 
    LEFT JOIN return_status as rs
    ON ist.issued_id = rs.issued_id
    WHERE return_id IS NULL AND
    (CURRENT_DATE - ist.issued_date ) >30

)
GROUP BY 1;

-- i Took Help of CHATGPT Here 
-- Task 18 and 20 is kind off HW for me ill do these both task by my own .
