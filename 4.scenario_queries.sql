-- QUERIES TO RETRIEVE DATA --------
-- 1. Create a class register for the class, with names and phone numbers of all the students who paid
-- 2. Get the name and contact of any student with missing payment and the amount they are due
-- 3. Check how many spots are available for drop-in students
-- 4. Get emails of all students interested in a class and send updated block dates, prices and class time schedule
-- 5. Get the total amount of payments received during a tax year and the reference to each payment

USE yoga_management;


-- 1. Get a class register from a specific period ---------------------------------

SET @class = 'THUR 13';
SET @from_date = '2022-11-01';
SET @to_date = '2022-11-15';

SELECT s.first_name, s.last_name, s.phone
FROM registers AS r
	INNER JOIN payments AS p
	ON r.payment_id = p.id
	INNER JOIN students AS s
	ON p.student_id = s.id
	WHERE r.class_id = (SELECT get_class_id(@class))
		AND p.block_id = (SELECT b.id FROM blocks AS b
							WHERE b.starting_date BETWEEN @from_date AND @to_date)
ORDER BY s.last_name, s.first_name ASC;
   
   
-- 2. Check for missing payments in the 15 days before a new block starts ---------------------------------

-- Find exact date of block starting between given dates
SET @from_date = '2022-11-01';
SET @to_date = '2022-11-15';
SET @deadline = get_block_start(@from_date, @to_date);

-- get the name and number of students who are late for payment, as well as total
SELECT
s.first_name, s.last_name, s.phone,
-- count the number of classes in the registers
(COUNT(r.class_id) * 
	-- find the price for the lesson block
	(SELECT b.price FROM blocks AS b
	WHERE b.starting_date = @deadline)
) AS amount_due
FROM registers AS r
LEFT JOIN payments AS p
ON r.student_id = p.student_id
INNER JOIN students AS s
ON s.id = r.student_id
-- filter the results for late or missing payments
WHERE p.paid_date IS NULL
	OR p.paid_date NOT BETWEEN DATE_SUB(@deadline, INTERVAL 15 DAY) AND @deadline
GROUP BY r.student_id
ORDER BY s.last_name, s.first_name ASC;

    
-- 3. Get the number of students attending each class in a specific block and calculate the available spots at that location ---------------------------------

SET @from_date = '2022-11-01';
SET @to_date = '2022-11-15';

SELECT
c.class_name,
students_count.paid,
(st.max_students - students_count.paid) AS available
FROM classes AS c
INNER JOIN (SELECT 
			r.class_id, COUNT(*) AS paid
			FROM registers AS r
            INNER JOIN payments AS p
            ON r.payment_id = p.id
            WHERE p.block_id = (SELECT b.id FROM blocks AS b
								WHERE b.starting_date 
								BETWEEN @from_date AND @to_date) 
			GROUP BY r.class_id) AS students_count
ON students_count.class_id = c.id
LEFT JOIN studios AS st
ON st.id = c.studio_id;


-- 4. In the weeks before a new block starts, get emails of all students interested in a class and send updated block dates, prices and class time schedule ---------------------------------
SET @class_name = 'MON 18';
SET @period_from = '2023-10-01';
SET @period_to = '2023-10-18';

-- Get the list of email for the class
SELECT s.email
FROM students AS s
WHERE s.id IN (SELECT r.student_id
				FROM registers AS r
				WHERE class_id = get_class_id(@class_name))
ORDER BY s.email ASC;

-- Get block dates, price and class schedule to write the email content
SELECT
DATE_FORMAT(b.starting_date, '%e %M %Y') AS block_starts,
DATE_FORMAT(b.ending_date, '%e %M %Y') AS block_ends,
c.week_day AS class_every,
TIME_FORMAT(c.starting_time, '%h:%i %p') AS class_from,
TIME_FORMAT(c.ending_time, '%h:%i %p') AS class_to,
s.studio_name AS at_studio,
@class_name AS payment_reference,
b.price AS £_total
FROM  blocks AS b
RIGHT JOIN classes AS c
ON c.class_name = @class_name
INNER JOIN studios AS s
ON s.id = c.studio_id
WHERE b.starting_date = get_block_start(@period_from, @period_to);


-- 5. Get the total amount of payments received during a tax year and the reference to each payment -------------------------------
SET @tax_year = '2022/2023';

-- Total amount of payments in that tax year
SELECT SUM(p.amount) AS total_earnings
FROM payments AS p
INNER JOIN tax_years AS t
ON p.paid_date BETWEEN t.starting_date AND t.ending_date;

-- List of payment reference, date and amount paid during that tax year
SELECT
p.id AS payment_id,
DATE_FORMAT(p.paid_date, '%d %b %Y')  AS paid_on,
p.amount AS £
FROM payments AS p
INNER JOIN tax_years AS t
ON p.paid_date BETWEEN t.starting_date AND t.ending_date
ORDER BY p.paid_date ASC;

-- QUERIES TO INSERT, UPDATE OR DELETE DATA FROM THE TABLES
-- 1. Add a new payment to the records
-- 2. Add a new student record
-- 3. Add new block of lessons
-- 4. Update a student phone number
-- 5. Delete a class from student preferences

-- 1. Add a new payment to the records and check if payment is correct -------------------------
-- The teacher has received a payment of £80.00 from Amelia Wilson on 12/01/2023
-- Use the procedure to add a payment. Requires 3 paramenters: (student id, the payment date, amount paid)
SET @payment_date = '2023-01-02';		 -- format required 'YYYY-MM-DD'
SET @amount_paid = 80.00;

-- Get the student id. Function requires 2 paramenters: the detail type (name, phone or email) and the value (both as strings)
SET @student_id = get_student_id('name', 'Amelia Wilson');

-- Check if amount paid is correct (negative 'owed' values means the student has overpaid)
SELECT 
(b.price * (SELECT COUNT(r.class_id)
				FROM registers AS r
				WHERE r.student_id = @student_id)) AS total_due,
@amount_paid AS paid,
(SELECT CAST(SUM(total_due - paid) AS DECIMAL(6,2))) AS owed
FROM blocks AS b
WHERE b.starting_date BETWEEN @payment_date AND DATE_ADD(@payment_date, INTERVAL 15 DAY);

-- Add the payment info to the payments table
CALL add_payment(@student_id, @payment_date, @amount_paid);

-- Verify successful insertion
SELECT * FROM payments AS p
WHERE p.paid_date = @payment_date
	AND p.student_id = @student_id;
    
-- 2. Add a new student record ----------------------
-- The teacher sends a form to fill to all new students, where the following data is collected in the following format:
SET @first_name = 'Maria';
SET @last_name = 'Martin';
SET @email = 'maria_martin@example.co.uk';
SET @phone = '+44 7334 1456777';
SET @classes = 'WED 12, FRI 18';

-- Procedure to add student requires all the above details as parameters
CALL add_student(@first_name, @last_name, @email, @phone, @classes);

-- Check if student details have been correctly added
SELECT * FROM students AS s
WHERE s.phone = @phone;

-- Check if register has been updated correctly
SELECT
r.student_id,
CONCAT(s.first_name, ' ', s.last_name) AS student,
c.class_name
FROM registers AS r
LEFT JOIN classes AS c
ON c.id = r.class_id
LEFT JOIN students AS s
ON s.id = r.student_id
WHERE r.student_id = get_student_id('phone', @phone);

-- 3. Add new block of lessons --------------------
-- Function requires paramenters: starting date, ending date, number of expected lessons (normally once a week) and the price per lesson
SET @starting_date = '2024-01-14';
SET @ending_date = '2024-02-05';
SET @lesson_count = 4;
SET @lesson_price = 9.80;

CALL add_block(@starting_date, @ending_date, @lesson_count, @lesson_price);

-- Check insertion was successful
SELECT * FROM blocks AS b
WHERE b.starting_date = @starting_date;


-- 4. Update a student phone number ---------------------------
SET @student = 'Sophia Clarke';
SET @new_phone = '+44 7711 090909';

-- Get the student id from the name
SET @student_id = get_student_id('name', @student);

-- Update table students with new phone number
UPDATE students AS s
SET s.phone = @new_phone
WHERE s.id = @student_id;

-- Check successful update in the register
SELECT
CONCAT(s.first_name, ' ', s.last_name) AS student,
s.phone AS phone
FROM students AS s
WHERE s.id = @student_id;


-- 5. Delete a class from student preferences -------------------------
-- Student Henry Thompson has decided to quit the Thursday lunch class
SET @student_id = get_student_id('name', 'Henry Thompson');

SET @class_id = (SELECT id FROM classes
					WHERE week_day = 'Thursday'
						AND starting_time BETWEEN '11:30:00' AND '14:30:00');

-- Check if Henry is registered to the class (before and after deletion)
SELECT
r.id,
r.student_id,
r.class_id,
CONCAT(s.first_name, ' ', s.last_name) AS student,
c.class_name
FROM registers AS r
LEFT JOIN classes AS c
ON c.id = r.class_id
RIGHT JOIN students AS s
ON s.id = r.student_id
WHERE r.student_id = @student_id
	AND r.class_id = @class_id;

-- Delete the row found
DELETE FROM registers AS r
WHERE r.class_id = @class_id
	AND r.student_id = @student_id;
    
-- Use the previous select to ensure the delete has been successful