# library_managment_system_sql_project
## Project Overview
This project involves designing and managing a Library Management System using PostgreSQL. The system allows users to manage books, members, employees, and transactions like book issuance and returns. The SQL queries and procedures in this project aim to perform common library operations such as adding new books, updating member details, issuing and returning books, and generating reports on library usage and performance.
## Key Features
#### Book Management: Add new books, update their details, and manage book status.
#### Member Management: Keep track of members, update their information, and track issued books.
#### Issuance & Returns: Manage book issuance and returns, track overdue books, and store return information.
#### Reporting & Analysis: Generate reports like branch performance, member activity, and overdue books.
## Database Entities
### Tables Used:
#### 1.Books: Stores book information (ISBN, title, author, price, status, etc.).
#### 2.Members: Keeps track of library members (ID, name, address, registration date, etc.).
#### 3.Employees: Contains employee details (ID, name, branch information, etc.).
#### 4.Issued Status: Tracks issued books (ID, employee, member, issued date, etc.).
#### 5.Return Status: Tracks returned books (ID, issued ID, return date, book quality, etc.).
#### 6.Branches: Contains branch information for library locations.
## SQL Tasks Breakdown
### Task 1: Create a New Book Record
This task adds a new book to the books table.
```sql

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B
```
### Task 2: Update an Existing Member's Address
This query updates a specific member's address.

```sql

UPDATE members
SET member_address = '125 main st'
WHERE member_id = 'C101';
```
### Task 3: Delete a Record from the Issued Status Table
This query removes a specific issued book entry.

```sql

DELETE FROM issued_status
WHERE issued_id = 'IS121';
```
### Task 4: Retrieve All Books Issued by a Specific Employee
Query to list all books issued by a particular employee.

``` sql

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```
### Task 5: List Members Who Have Issued More Than One Book
Use GROUP BY and HAVING to find members with multiple issued books.

```sql

SELECT issued_status.issued_emp_id, emp_name, COUNT(issued_status.issued_id) AS num_books
FROM employees 
JOIN issued_status ON employees.emp_id = issued_status.issued_emp_id
GROUP BY issued_status.issued_emp_id, emp_name
HAVING COUNT(issued_status.issued_id) > 1;
```
### Task 6: Create Summary Tables
Using CTAS (Create Table As Select) to generate summary tables.

```sql
CREATE TABLE book_cnts AS 
SELECT books.isbn, books.book_title, COUNT(issued_status.issued_id) 
FROM books 
JOIN issued_status ON issued_status.issued_book_isbn = books.isbn
GROUP BY books.isbn, books.book_title;
```
### Task 7: Retrieve All Books in a Specific Category
Select all books that fall under a particular category.

``` sql

SELECT * FROM books
WHERE category = 'Classic'
;
```
### Task 8: Find Total Rental Income by Category
This query calculates the total rental income for each category.

```sql

SELECT category, SUM(rental_price), COUNT(issued_status.issued_book_isbn)
FROM books 
JOIN issued_status ON books.isbn = issued_status.issued_book_isbn
GROUP BY category;
```
### Task 9: List Members Who Registered in the Last 180 Days
``` sql

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```
### Task 10: List Employees with Their Branch Manager's Name
Join employees with their respective branch manager and branch details.

```sql

SELECT e1.emp_name AS EmployeeName, e2.emp_name AS ManagerName
FROM employees e1
JOIN branch b ON e1.branch_id = b.branch_id
JOIN employees e2 ON b.manager_id = e2.emp_id;
```
### Task 11: Create a Table of Books with Rental Price Above 7 USD
```sql

CREATE TABLE books_above_7USD AS 
SELECT * FROM books
WHERE rental_price > 7;
```
### Task 12: List Unreturned Books
Identify books that have not been returned.

```sql

SELECT DISTINCT issued_status.issued_book_name 
FROM issued_status
LEFT JOIN return_status ON return_status.issued_id = issued_status.issued_id
WHERE return_status.return_id IS NULL;
```
### Task 13: Identify Members with Overdue Books
Query to list overdue books with a return period exceeding 30 days.

``` sql

SELECT issued_status.issued_book_name, issued_status.issued_date, members.member_name, 
       CURRENT_DATE - issued_status.issued_date AS days_overdue
FROM issued_status 
JOIN members ON members.member_id = issued_status.issued_member_id
JOIN books ON books.isbn = issued_status.issued_book_isbn
LEFT JOIN return_status ON return_status.issued_id = issued_status.issued_id
WHERE return_status.return_id IS NULL 
  AND CURRENT_DATE - issued_status.issued_date > 30;
```
### Task 14: Book Return Procedure
This task defines a stored procedure to process book returns.
``` sql

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
LANGUAGE plpgsql AS $$
DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);
BEGIN
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT issued_book_isbn, issued_book_name INTO v_isbn, v_book_name
    FROM issued_status WHERE issued_id = p_issued_id;

    UPDATE books SET status = 'yes' WHERE isbn = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;
```
### Task 15: Branch Performance Report
Generate performance reports for each branch, showing books issued, returned, and revenue.

```sql

CREATE TABLE branch_report AS
SELECT branch.branch_id, COUNT(issued_status.issued_book_name) AS issued_books,
       COUNT(return_status.return_id) AS returned_books, SUM(books.rental_price) AS total_revenue
FROM branch 
JOIN employees ON branch.branch_id = employees.branch_id
JOIN issued_status ON employees.emp_id = issued_status.issued_emp_id
LEFT JOIN return_status ON issued_status.issued_id = return_status.issued_id
JOIN books ON issued_status.issued_book_isbn = books.isbn
GROUP BY branch.branch_id;
```
### Task 16: Create Table of Active Members
Create a table for members who issued books within the last 2 months.

```sql

CREATE TABLE active_members AS
SELECT members.*
FROM members
JOIN issued_status ON issued_status.issued_member_id = members.member_id
WHERE issued_status.issued_date >= CURRENT_DATE - INTERVAL '2 months';
```
### Task 17: Employees with the Most Books Issued
Find the top 3 employees who processed the most book issues.

```sql

SELECT employees.emp_name, branch.branch_id, COUNT(issued_status.issued_book_isbn) AS books_processed
FROM employees 
JOIN issued_status ON employees.emp_id = issued_status.issued_emp_id
JOIN branch ON branch.branch_id = employees.branch_id
GROUP BY employees.emp_name, branch.branch_id
ORDER BY books_processed DESC
LIMIT 3;
```
## Conclusion
The queries and procedures in this project showcase essential tasks for managing a library database, including data entry, updates, deletion, and reporting. With PostgreSQL's robust capabilities, the library's day-to-day operations and performance can be efficiently monitored and managed.
