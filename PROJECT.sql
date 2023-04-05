--EXECUTE FROM ADMIN_YASH

--CLEANUP SCRIPT
set serveroutput on
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
begin
   dbms_output.put_line('Start schema cleanup');
   for i in (
             select 'ORDERS' table_name from dual union all
             select 'CUSTOMER' table_name from dual union all
             select 'INVENTORY' table_name from dual union all
             select 'EMPLOYEE' table_name from dual union all
             select 'STORE' table_name from dual union all
             select 'ADDRESS' table_name from dual union all
             select 'BOOKAUTHOR' table_name from dual union all
             select 'BOOK' table_name from dual union all
             select 'PUBLISHER' table_name from dual union all
             select 'AUTHOR' table_name from dual
   )
   loop
   dbms_output.put_line('....Drop table '||i.table_name);
   begin
       select 'Y' into v_table_exists
       from USER_TABLES
       where TABLE_NAME=i.table_name;

       v_sql := 'drop table '||i.table_name;
       execute immediate v_sql;
       dbms_output.put_line('........Table '||i.table_name||' dropped successfully');
       
   exception
       when no_data_found then
           dbms_output.put_line('........Table already dropped');
   end;
   end loop;
   dbms_output.put_line('Schema cleanup successfully completed');
exception
   when others then
      dbms_output.put_line('Failed to execute code:'||sqlerrm);
end;
/


create table author(
authorid number PRIMARY KEY,
authorname varchar(50) NOT NULL
)
/

create table publisher(
publisherid number PRIMARY KEY,
publishername varchar(50) NOT NULL
)
/

create table book(
bookid number PRIMARY KEY,
title varchar(50) NOT NULL,
isbn number NOT NULL,
genre varchar(50) NOT NULL,
publicationyear number NOT NULL,
publicationid number REFERENCES publisher(publisherid) NOT NULL,
price number NOT NULL
)
/

create table bookauthor(
bookid number REFERENCES book(bookid) NOT NULL,
authorid number REFERENCES author(authorid)NOT NULL
)
/

create table address (
addressid number PRIMARY KEY,
streetnumber number NOT NULL,
streetname varchar(50) NOT NULL,
city varchar(50) NOT NULL,
state varchar(50) NOT NULL,
postalcode number NOT NULL,
country varchar(50) NOT NULL
)
/

create table store(
storeid number PRIMARY KEY,
addressid number REFERENCES address(addressid) NOT NULL,
phonenumber number NOT NULL
)
/

create table employee(
employeeid number PRIMARY KEY,
storeid number REFERENCES store(storeid) NOT NULL,
employeefirstname varchar(50) NOT NULL,
employeelastname varchar(50) NOT NULL,
addressid number REFERENCES address(addressid) NOT NULL,
salary number NOT NULL
)
/

create table inventory(
storeid number REFERENCES store(storeid),
bookid number REFERENCES book(bookid) NOT NULL,
quantity number NOT NULL
)
/

create table customer(
customerid number PRIMARY KEY,
firstname varchar(50) NOT NULL,
lastname varchar(50) NOT NULL,
gender varchar(50) NOT NULL,
addressid number REFERENCES address(addressid) NOT NULL,
email varchar(50) NOT NULL
)
/

create table orders(
orderid number PRIMARY KEY,
customerid number REFERENCES customer(customerid) NOT NULL,
bookid number REFERENCES book(bookid) NOT NULL,
quantity number NOT NULL,
price number NOT NULL,
subtotal float NOT NULL,
tax float NOT NULL,
total float NOT NULL,
payment varchar(50) NOT NULL
)
/
--inserting data to author
INSERT INTO author VALUES (1, 'J.K. Rowling');
INSERT INTO author VALUES (2, 'Stephen King');
INSERT INTO author VALUES (3, 'Chimamanda Ngozi Adichie');
INSERT INTO author VALUES (4, 'Margaret Atwood');
INSERT INTO author VALUES (5, 'Haruki Murakami');
INSERT INTO author VALUES (6, 'Toni Morrison');
INSERT INTO author VALUES (7, 'Neil Gaiman');
INSERT INTO author VALUES (8, 'David Mitchell');
INSERT INTO author VALUES (9, 'George Orwell');
INSERT INTO author VALUES (10, 'Gabriel Garcia Marquez');


--inserting data to publisher
INSERT INTO publisher VALUES (1, 'Penguin Random House');
INSERT INTO publisher VALUES (2, 'Simon Schuster');
INSERT INTO publisher VALUES (3, 'HarperCollins');
INSERT INTO publisher VALUES (4, 'Macmillan Publishers');
INSERT INTO publisher VALUES (5, 'Hachette Livre');
INSERT INTO publisher VALUES (6, 'Bloomsbury Publishing');
INSERT INTO publisher VALUES (7, 'Scholastic Corporation');
INSERT INTO publisher VALUES (8, 'Pearson Education');
INSERT INTO publisher VALUES (9, 'Oxford University Press');
INSERT INTO publisher VALUES (10, 'Cambridge University Press');


--inserting data to book
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (1, 'To Kill a Mockingbird', 9780061120084, 'Classic', 1960, 1, 10.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (2, '1984', 9780451524935, 'Dystopian', 1949, 2, 12.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (3, 'The Great Gatsby', 9780743273565, 'Classic', 1925, 3, 9.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (4, 'The Catcher in the Rye', 9780316769488, 'Coming of age', 1951, 4, 11.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (5, 'Harry Potter and the Philosophers Stone', 9780747532743, 'Fantasy', 1997, 5, 13.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (6, 'The Lord of the Rings', 9780544003415, 'Fantasy', 1954, 6, 25.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (7, 'The Hunger Games', 9780439023528, 'Dystopian', 2008, 7, 14.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (8, 'Pride and Prejudice', 9780486284736, 'Romance', 1813, 8, 8.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (9, 'The Hitchhikers Guide to the Galaxy', 9780345391803, 'Science Fiction', 1979, 9, 15.99);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (10, 'The Hobbit', 9780547928227, 'Fantasy', 1937, 10, 10.99);


--inserting data to bookauthor
INSERT INTO bookauthor VALUES(1,1);
INSERT INTO bookauthor VALUES(2,2);
INSERT INTO bookauthor VALUES(3,3);
INSERT INTO bookauthor VALUES(4,4);
INSERT INTO bookauthor VALUES(5,5);
INSERT INTO bookauthor VALUES(6,6);
INSERT INTO bookauthor VALUES(7,7);
INSERT INTO bookauthor VALUES(8,8);
INSERT INTO bookauthor VALUES(9,9);
INSERT INTO bookauthor VALUES(10,10);

--inserting data to address
INSERT INTO address VALUES (1, 1234, 'Elm Street', 'Springfield', 'IL', 62704, 'USA');
INSERT INTO address VALUES (2, 5678, 'Main Street', 'Smalltown', 'CA', 90210, 'USA');
INSERT INTO address VALUES (3, 9876, 'Oak Lane', 'Greenville', 'NC', 27858, 'USA');
INSERT INTO address VALUES (4, 4321, 'Maple Avenue', 'Burlington', 'VT', 05401, 'USA');
INSERT INTO address VALUES (5, 555, 'Broadway', 'New York', 'NY', 10012, 'USA');
INSERT INTO address VALUES (6, 789, 'Cedar Lane', 'Ann Arbor', 'MI', 48104, 'USA');
INSERT INTO address VALUES (7, 321, 'Willow Road', 'Redwood City', 'CA', 94063, 'USA');
INSERT INTO address VALUES (8, 456, 'Pine Street', 'Portland', 'ME', 04101, 'USA');
INSERT INTO address VALUES (9, 987, 'Magnolia Boulevard', 'Burbank', 'CA', 91501, 'USA');
INSERT INTO address VALUES (10, 2468, 'Fifth Avenue', 'Seattle', 'WA', 98101, 'USA');
INSERT INTO address VALUES (11, 7890, 'Cherry Street', 'Kansas City', 'MO', 64106, 'USA');
INSERT INTO address VALUES (12, 111, 'Westminster Road', 'Brooklyn', 'NY', 11218, 'USA');
INSERT INTO address VALUES (13, 222, 'Sycamore Lane', 'Columbus', 'OH', 43215, 'USA');
INSERT INTO address VALUES (14, 333, 'Birch Street', 'Birmingham', 'AL', 35203, 'USA');
INSERT INTO address VALUES (15, 444, 'Chestnut Avenue', 'Louisville', 'KY', 40202, 'USA');
INSERT INTO address VALUES (16, 555, 'Maple Road', 'Oklahoma City', 'OK', 73102, 'USA');
INSERT INTO address VALUES (17, 666, 'Holly Drive', 'Scottsdale', 'AZ', 85250, 'USA');
INSERT INTO address VALUES (18, 777, 'Dogwood Street', 'Asheville', 'NC', 28801, 'USA');
INSERT INTO address VALUES (19, 888, 'Palm Boulevard', 'Miami', 'FL', 33132, 'USA');
INSERT INTO address VALUES (20, 999, 'Cypress Avenue', 'New Orleans', 'LA', 70112, 'USA');

--inserting data to store
INSERT INTO store (storeid, addressid, phonenumber) VALUES (1, 1, 8573131234);
INSERT INTO store (storeid, addressid, phonenumber) VALUES (2, 2, 6175551212);
INSERT INTO store (storeid, addressid, phonenumber) VALUES (3, 3, 2125555555);
INSERT INTO store (storeid, addressid, phonenumber) VALUES (4, 4, 3125555555);
INSERT INTO store (storeid, addressid, phonenumber) VALUES (5, 5, 4155555555);


--inserting data to employee
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (1, 1, 'Steven', 'Ponting', 6, 90000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (2, 2, 'Emily', 'Wong', 7, 80000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (3, 3, 'John', 'Smith', 8, 70000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (4, 4, 'Sarah', 'Johnson', 9, 85000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (5, 5, 'Mike', 'Davis', 10, 75000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (6, 1, 'Zach', 'Clinton', 11, 55000);

--inserting data to inventory
INSERT INTO inventory (storeid, bookid, quantity) VALUES (1, 1, 50);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (2, 2, 25);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (3, 3, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (4, 4, 75);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5, 5, 10);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (1, 5, 10);

--inserting data to customer
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (1, 'Rick', 'Hayden', 'Male', 11, 'rickhayden@gmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (2, 'Sarah', 'Lee', 'Female', 12, 'sarahlee@hotmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (3, 'John', 'Doe', 'Male', 13, 'johndoe@yahoo.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (4, 'Emily', 'Chen', 'Female', 14, 'emilychen@gmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (5, 'Mike', 'Nguyen', 'Male', 15, 'mikenguyen@gmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (6, 'Avery', 'Parker', 'Male', 16, 'averyparker@yahoo.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (7, 'Grace', 'Kim', 'Female', 17, 'gracekim@gmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (8, 'Jacob', 'Garcia', 'Male', 18, 'jacobgarcia@hotmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (9, 'Lily', 'Tran', 'Female', 19, 'lilytran@yahoo.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (10, 'David', 'Wu', 'Male', 20, 'davidwu@gmail.com');

--inserting data to orders
INSERT INTO orders(orderid, customerid, bookid, quantity, price, subtotal, tax, total, payment) VALUES (1, 1, 1, 2, 100, 2*100 , 18, 218, '1234567890');
INSERT INTO orders(orderid, customerid, bookid, quantity, price, subtotal, tax, total, payment) VALUES (2, 2, 2, 3,  50,  3*50 , 19, 169, '2345678901');
INSERT INTO orders(orderid, customerid, bookid, quantity, price, subtotal, tax, total, payment) VALUES (3, 3, 3, 4,  20, 4*20 , 12,  92, '3456789012');
INSERT INTO orders(orderid, customerid, bookid, quantity, price, subtotal, tax, total, payment) VALUES (4, 4, 4, 5,  30, 3*50 , 15, 165, '4567890123');
INSERT INTO orders(orderid, customerid, bookid, quantity, price, subtotal, tax, total, payment) VALUES (5, 5, 5, 6,  80, 6*80 , 09, 489, '5678901234');
INSERT INTO orders(orderid, customerid, bookid, quantity, price, subtotal, tax, total, payment) VALUES (6, 1, 4, 3,  60, 3*60 , 09, 189, '5432101234');

/