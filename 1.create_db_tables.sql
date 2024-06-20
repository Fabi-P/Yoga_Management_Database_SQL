-- This file contains all the queries to create the database and its tables
CREATE DATABASE yoga_management;

USE yoga_management;

-- Table to store students details
CREATE TABLE students (
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(30) UNIQUE NOT NULL
);

-- Table to store studios details
CREATE TABLE studios (
	id INT PRIMARY KEY AUTO_INCREMENT,
    studio_name VARCHAR(50) NOT NULL UNIQUE,
    house_number VARCHAR(10),
    street VARCHAR(50) NOT NULL,
    village VARCHAR(30) NOT NULL,
    postcode VARCHAR(7) NOT NULL,
    max_students INT NOT NULL
);

-- Table to store classes details
CREATE TABLE classes (
	id INT PRIMARY KEY AUTO_INCREMENT,
    class_name VARCHAR(7) NOT NULL UNIQUE,
    week_day VARCHAR(20),
    starting_time TIME,
    ending_time TIME,
    studio_id INT,
    CONSTRAINT fk_class_studio
		FOREIGN KEY (studio_id)
		REFERENCES studios(id)
);


-- Table to store the tax-years
CREATE TABLE tax_years (
	id INT PRIMARY KEY AUTO_INCREMENT,
    tax_year VARCHAR(9),
    starting_date DATE NOT NULL,
    ending_date DATE NOT NULL
);

-- Table to store the blocks of lessons dates and prices
CREATE TABLE blocks (
	id INT PRIMARY KEY AUTO_INCREMENT,
	starting_date DATE NOT NULL,
    ending_date DATE NOT NULL,
    lesson_count INT NOT NULL,
    price DECIMAL(6, 2),
    tax_year_id INT,
    CONSTRAINT fk_block_year
		FOREIGN KEY (tax_year_id)
		REFERENCES tax_years(id)
);
	
-- Table to store student payments details
CREATE TABLE payments (
	id INT PRIMARY KEY AUTO_INCREMENT,
    paid_date DATE,
    amount DECIMAL(6, 2) NOT NULL,
    student_id INT NOT NULL,
    block_id INT NOT NULL,
    CONSTRAINT fk_paying_student 
		FOREIGN KEY(student_id)
		REFERENCES students(id),
	CONSTRAINT fk_block_paid
		FOREIGN KEY (block_id)
        REFERENCES blocks(id)
);

-- Table to join the payments with the classes
CREATE TABLE registers (
	id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    payment_id INT,
    class_id INT NOT NULL,
    CONSTRAINT fk_student
		FOREIGN KEY (student_id)
        REFERENCES students(id),
    CONSTRAINT fk_payment
		FOREIGN KEY (payment_id)
        REFERENCES payments(id),
	CONSTRAINT fk_class
		FOREIGN KEY (class_id)
		REFERENCES classes(id)
);

