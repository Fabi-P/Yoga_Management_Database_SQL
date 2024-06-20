USE yoga_management;

-- Create function to find the tax ID from a date
DELIMITER //
CREATE FUNCTION IF NOT EXISTS find_tax_year_id(
    reference_date DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE tax_id INT;
    SET tax_id = 
		(SELECT t.id FROM tax_years AS t
		WHERE reference_date 
		BETWEEN t.starting_date AND t.ending_date);
        RETURN tax_id;
END//
DELIMITER ;


-- Create procedure to add TABLE blocks
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS add_block(
	IN starting_date DATE,
    IN ending_date DATE,
    IN lesson_count INT,
    IN price_per_lesson DECIMAL(6, 2)
)
BEGIN
	
	DECLARE total_price DECIMAL(6, 2);
	DECLARE tax_year_id INT;
    
    -- Calculate the price of the block
    SET total_price = lesson_count * price_per_lesson;
    
    -- Find the tax_year_id using the function
    SET tax_year_id = find_tax_year_id(starting_date);
    
	INSERT INTO blocks
		(starting_date, ending_date, lesson_count, price, tax_year_id)
	VALUES
		(starting_date, ending_date, lesson_count, total_price, tax_year_id);
END //
DELIMITER ;
 

-- Create procedure to add a new student
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS add_student (
    IN first_name VARCHAR(50),
    IN last_name VARCHAR(50),
    IN email VARCHAR(50),
    IN phone VARCHAR(20),
    IN classes VARCHAR(50)
)
BEGIN
	-- Add students details to TABLE students
	INSERT INTO students
		(first_name, last_name, email, phone)
    VALUES 
		(first_name, last_name, email, phone);
        
	-- Get student_id from the new record
    SET @student_id = (SELECT s.id FROM students AS s
						WHERE s.phone = phone
							AND s.email = email);
                            
    -- Add student class preferences to TABLE registers
	WHILE LENGTH(classes) > 0 DO
		SET @comma_pos = (SELECT LOCATE(',', classes));
        -- If there is no comma, the reference is for a single class
        IF @comma_pos = 0 THEN
			SET @class = classes;
            SET classes = '';
		ELSE
			SET @class = (SELECT SUBSTRING(classes, 1, @comma_pos - 1));
            SET classes = (SELECT SUBSTRING(classes FROM @comma_pos + 1));
		END IF;
        
        -- Find class id thorugh its name
		SET @class_id = get_class_id(@class);
        
        -- Add class preference to TABLE registers
        INSERT INTO registers
			(student_id, class_id)
		VALUES
			(@student_id, @class_id);
        
    END WHILE;
END//
DELIMITER ;


-- Create function to find a student id
DELIMITER //
CREATE FUNCTION IF NOT EXISTS get_student_id(
    detail_type VARCHAR(50),
    detail_value VARCHAR(50)
) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE student_id INT;
    IF detail_type = 'phone' THEN
        SET @phone = detail_value;
        SET student_id = (SELECT s.id FROM students AS s
							WHERE s.phone = @phone);
                            
    ELSEIF detail_type = 'email' THEN
        SET @email = detail_value;
        SET student_id = (SELECT s.id FROM students AS s
							WHERE s.email = @email);
                            
    ELSEIF detail_type = 'name' THEN
		SET @first_name = (SELECT SUBSTRING_INDEX(detail_value, ' ', 1));
        SET @last_name = (SELECT SUBSTRING_INDEX(detail_value, ' ', -1));
        SET student_id = (SELECT s.id FROM students AS s
							WHERE s.first_name = @first_name
								AND s.last_name = @last_name); 
    END IF;
    RETURN (student_id);
END//
DELIMITER ;

-- Create function to find class id
DELIMITER //
CREATE FUNCTION IF NOT EXISTS get_class_id
	(class_reference VARCHAR(10))
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE id INT;
	SET class_reference = UPPER(TRIM(class_reference));
	SET id = (SELECT c.id FROM classes AS c
			WHERE c.class_name = class_reference);
    RETURN id;
END //
DELIMITER ;


-- Create procedure to add a payment
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS add_payment(
	IN student_id INT,
    IN paid_date DATE,
    IN amount DECIMAL(6, 2)
)
BEGIN
    -- Find block id from date (any date for 2 weeks previous to block starts)
	DECLARE block_id INT;
    SET block_id = (
		SELECT b.id FROM blocks AS b
		WHERE b.starting_date
			BETWEEN paid_date AND DATE_ADD(paid_date, INTERVAL 15 DAY)
	);
    
    -- Add record to table payments
    INSERT INTO payments
		(paid_date, amount, student_id, block_id)
	VALUES
		(paid_date, amount, student_id, block_id);
	
    -- get payment id from new record
    SET @payment_id = (SELECT p.id FROM payments AS p
						WHERE p.paid_date = paid_date
							AND p.student_id = student_id);
          
	-- Update TABLE registers with most updated payment
	UPDATE registers AS r
	SET r.payment_id = @payment_id
	WHERE r.student_id = student_id;
END //
DELIMITER ;

-- Create function to find a block exact starting date within a given period
DELIMITER //
CREATE FUNCTION IF NOT EXISTS get_block_start(
	from_date DATE,
    to_date DATE
)
RETURNS DATE
DETERMINISTIC
BEGIN
	-- find exact starting date of a block
    DECLARE block_start DATE;
    SET block_start = (SELECT b.starting_date FROM blocks AS b
						WHERE b.starting_date BETWEEN from_date AND to_date);
	RETURN block_start;
END//
DELIMITER ;