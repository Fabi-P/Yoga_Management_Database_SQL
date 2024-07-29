# YOGA MANAGEMENT DATABASE

This database is designed to support a yoga instructor to keep an organised record of all details needed to run their small business.
Students details can be easily added, updated and retrieved to efficiently send communications about classes dates, times and pricing. 
This database would be perfect to create a web app to manage bookings and payments.

The database also allows to keep a well organised record of all payments received by each student in relation to each class. This allows to easily identify students who have missed a payment so that a reminder can be sent. 
The teacher can also easily retrieve accurate information on all payments to complete tax reports and could use the database to run business analysis in the future.

![Database Architecture Flowchart](https://github.com/user-attachments/assets/5bd9dd10-54e1-4d51-b120-5528a560fd70)

### REQUIREMENTS

MySQL Workbench

### SET UP:
Run the queries in the 4 files following their naming order.
Files 1 to 3 can be run atomatically to set up the database.
File 4 has queries best run individually as they perform diverse tasks.
Read the FILE CONTENTS for more details on each file. 

### FILES CONTENTS:

1. create_db_tables
This file contains all the queries to create the database and its tables.
It can be run as whole as a first step and will create:

- TABLE students: names and contact details of all students
- TABLE studios: names, locations and capacity of the yoga studio used
- TABLE classes: schedule and locations of the classes taught
- TABLE tax_years: dates of different tax years for the business records
- TABLE blocks: dates, number of lessons and price of blocks of lessons
- TABLE payments: record of all payments received from students
- TABLE registers: joins TABLE students, payments and classes

2. create_procedures_functions
This file contains all the stored procedures and functions that support the use of the database.
It can be run as a whole after the database and tables have been created.

3. populate_tables
This file will populate all tables with sample data.
Each table can be populated separately and is followed by a query to check if the data has been inserted correctly.
The file can also be run as a whole to populate all the tables.
Most query use the stored functions and procedures from file 2.

4. scenario_queries
This file contains specific queries to manage different scenarios that could happen in the running of a yoga business.

### QUERIES TO RETRIEVE DATA
1. Create a class register for the class, with names and phone numbers of all the students who paid
2. Get the name and contact of any student with missing payment and the amount they are due
3. Check how many spots are available for drop-in students
4. Get emails of all students interested in a class and send updated block dates, prices and class time schedule
5. Get the total amount of payments received during a tax year and the reference to each payment

### QUERIES TO INSERT, UPDATE OR DELETE DATA FROM THE TABLES
1. Add a new payment to the records
2. Add a new student record
3. Add new block of lessons
4. Update a student phone number
5. Delete a class from student preferences

Titles and numberation is consistent within the file, along with more comments to clarify parts of the queries.
