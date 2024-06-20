USE yoga_management;

-- Populating TABLE studios with locations
INSERT INTO studios
	(studio_name, house_number, street, village, postcode, max_students)
VALUES
	('Studio72', '12a', 'High Street', 'Aberdour', 'KY3 0SW', 10),
    ('The Upstairs', '178', 'Amblehurst Close', 'Burntisland', 'KY3 3SU', 12); 

-- Check if insertion was successful
SELECT * FROM studios;



-- Populating TABLE classes
INSERT INTO classes
	(class_name, week_day, starting_time, ending_time, studio_id)
VALUES
	('SUN 19', 'Sunday', '19:00:00', '20:30:00', 1),
    ('MON 18', 'Monday', '18:30:00', '19:45:00', 2),
    ('TUE 13', 'Tuesday', '13:15:00', '14:30:00', 2),
    ('WED 20', 'Wednesday', '20:00:00', '21:15:00', 1),
    ('WED 12', 'Wednesday', '12:00:00', '13:15:00', 2),
    ('THUR 13', 'Thursday', '13:15:00', '14:30:00', 2),
    ('THUR 20', 'Thursday', '20:00:00', '21:15:00', 2),
    ('FRI 18', 'Friday', '18:30:00', '19:45:00', 1);
    
-- Check if insertion was successful
SELECT * FROM classes;



-- Populating TABLE tax_years
INSERT INTO tax_years
	(tax_year, starting_date, ending_date)
VALUES
	('2023/2022', '2022-04-06', '2023-04-05'),
	('2023/2024', '2023-04-06', '2024-04-05'),
    ('2024/2025', '2024-04-06', '2025-04-05');
    
-- Check if insertion was successful
SELECT * FROM tax_years;



-- Populating TABLE blocks by calling the procedure
CALL add_block('2022-10-02', '2022-11-12', 5, 8.00);
CALL add_block('2022-11-13', '2022-12-17', 5, 8.00);
CALL add_block('2023-01-08', '2023-02-04', 4, 8.50);
CALL add_block('2023-02-05', '2023-03-18', 6, 8.50);
CALL add_block('2023-04-09', '2023-05-13', 5, 8.50);
CALL add_block('2023-05-14', '2023-06-24', 5, 8.50);
CALL add_block('2023-08-27', '2023-10-14', 7, 8.50);
CALL add_block('2023-10-15', '2023-11-18', 5, 9.00);
CALL add_block('2023-11-19', '2023-12-16', 4, 9.00);

-- Check if insertion was successful
SELECT * FROM blocks;



-- Populating TABLE students by calling the procedure
CALL add_student('Laura', 'Johnson', 'laura.johnson@example.com', '+44 7771 834675', 'SUN 19');
CALL add_student('Oliver', 'Smith', 'oliver.smith@example.com', '+44 7712 345678', 'TUE 13');
CALL add_student('Charlotte', 'Davies', 'charlotte.davies@example.com', '+44 7890 123456', 'TUE 13');
CALL add_student('Henry', 'Thompson', 'henry.thompson@example.com', '+44 7402 987654', 'TUE 13, WED 20, THUR 13');
CALL add_student('Emily', 'Johnson', 'emily.johnson@example.com', '+44 7501 234567', 'WED 20, THUR 13');
CALL add_student('Amelia', 'Wilson', 'amelia.wilson@example.com', '+44 7777 876543', 'SUN 19, MON 18');
CALL add_student('Thomas', 'Robinson', 'thomas.robinson@example.com', '+44 7908 123456', 'WED 20, MON 18');
CALL add_student('Sophia', 'Clarke', 'sophia.clarke@example.com', '+44 7987 654321', 'SUN 19');
CALL add_student('Edward', 'Jones', 'edward.jones@example.com', '+44 7364 987654', 'WED 20, MON 18, THUR 13');

-- Check if details were successfully inserted
SELECT * FROM students;



-- Populating TABLE payments by calling the procedure
CALL add_payment(get_student_id('name', 'Laura Johnson'), '2022-11-08', 40.00);
CALL add_payment(get_student_id('name', 'Sophia Clarke'), '2022-11-10', 40.00);
CALL add_payment(get_student_id('name', 'Amelia Wilson'), '2022-11-11', 80.00);
CALL add_payment(get_student_id('name', 'Oliver Smith'), '2022-11-11', 40.00);
CALL add_payment(get_student_id('name', 'Charlotte Davies'), '2022-11-12', 40.00);
CALL add_payment(get_student_id('name', 'Henry Thompson'), '2022-11-12', 120.00);
CALL add_payment(get_student_id('name', 'Emily Johnson'), '2022-11-12', 80.00);
CALL add_payment(get_student_id('name', 'Thomas Robinson'), '2022-11-13', 80.00);

-- Check if details were successfully inserted
SELECT * FROM payments;
