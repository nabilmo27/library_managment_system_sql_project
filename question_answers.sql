-- Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT into books (isbn,book_title,category,rental_price,status,author,publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address ='125 main st'
WHERE member_id='C101';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121'

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.





SELECT issued_status.issued_emp_id,emp_name, count(issued_status.issued_id)num_books from 
employees JOIN issued_status
ON employees.emp_id = issued_status.issued_emp_id
group by 1,2
HAVING  count(issued_status.issued_id) >1;


-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS   
SELECT books.isbn,books.book_title,count(issued_status.issued_id) from  books join issued_status 
ON issued_status.issued_book_isbn = books.isbn
group by 1,2



-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'

-- Task 8: Find Total Rental Income by Category:

select category,sum(rental_price),count(issued_status.issued_book_isbn)
from books join issued_status 
on books.isbn = issued_status.issued_book_isbn
group by 1

-- task 9:List Members Who Registered in the Last 180 Days:
select* from members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'


-- task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT e1.* AS EmployeeName, e2.emp_name AS ManagerName
FROM employees e1
JOIN branch b ON e1.branch_id = b.branch_id
JOIN employees e2 ON b.manager_id = e2.emp_id;



-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
CREATE TABLE  books_above_7USD as
select * from books
where rental_price>7

select*from books_above_7USD

-- task 12

select* from return_status


SELECT distinct issued_status.issued_book_name from issued_status
left join return_status
on return_status.issued_id = issued_status.issued_id
where return_status.return_id is NULL

/*Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30 
select issued_status.issued_book_name,issued_status.issued_date,members.member_name ,CURRENT_DATE-issued_status.issued_date as days_overdue
FROM issued_status 
JOIN 
members 
    ON members.member_id = issued_status.issued_member_id
JOIN 
books 
ON books.isbn = issued_status.issued_book_isbn
LEFT JOIN 
return_status 
ON return_status.issued_id = issued_status.issued_id

where return_status.return_id is null and CURRENT_DATE-issued_status.issued_date > 30
---task 14---------------------------------------------------------------------------------------------


SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-330-25864-8';
-- IS104

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';

-- 
INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES
('RS125', 'IS130', CURRENT_DATE, 'Good');
SELECT * FROM return_status
WHERE issued_id = 'IS130';


-- Store Procedures
CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
    
BEGIN
    -- all your logic and code
    -- inserting into returns based on users input
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES
    (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT 
        issued_book_isbn,
        issued_book_name
        INTO
        v_isbn,
        v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
    
END;
$$
    



-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');



-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');







/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
CREATE table branch_report as 
SELECT branch.branch_id,
count(issued_status.issued_book_name) issued_books,
count(return_status.return_id) returned_books 
,sum(books.rental_price) 
from 
branch join employees
on branch.branch_id = employees.branch_id
join issued_status
on employees.emp_id =issued_status.issued_emp_id
left join return_status 
on issued_status.issued_id =return_status.issued_id
join books on issued_status.issued_book_isbn = books.isbn
group by 1
select * from branch_report

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

CREATE TABLE active_members
AS
select members.* from members
join issued_status issued_status ON issued_status.issued_member_id = members.member_id
where issued_status.issued_date>= CURRENT_DATE-interval '2 months'

- 
-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
select employees.emp_name ,branch.branch_id,count(issued_status.issued_book_isbn) from 
employees join issued_status
on employees.emp_id = issued_status.issued_emp_id
join branch on branch.branch_id = employees.branch_id
group by 1,2
order by count(issued_status.issued_book_isbn) desc

