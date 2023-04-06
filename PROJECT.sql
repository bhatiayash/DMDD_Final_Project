
--**********************************************************************************

--EXECUTE FROM ADMIN_YASH

--CLEANUP SCRIPT
set serveroutput on
declare
    v_table_exists varchar(1) := 'Y';
    v_sql varchar(2000);
    v_sequence_exists varchar(1) := 'Y';
    v_sql_1 varchar(2000);
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
   
   -- Drop sequences
    FOR i IN (
        SELECT 'ADDRESS_ID_SEQ' sequence_name FROM dual UNION ALL
        SELECT 'AUTHOR_ID_SEQ' sequence_name FROM dual UNION ALL
        SELECT 'PUBLISHER_ID_SEQ' sequence_name FROM dual UNION ALL
        SELECT 'BOOK_ID_SEQ' sequence_name FROM dual UNION ALL
        SELECT 'STORE_ID_SEQ' sequence_name FROM dual UNION ALL
        SELECT 'EMPLOYEE_ID_SEQ' sequence_name FROM dual UNION ALL
        SELECT 'CUSTOMER_ID_SEQ' sequence_name FROM dual UNION ALL
        SELECT 'ORDERS_ID_SEQ' sequence_name FROM dual
    )
    LOOP
    dbms_output.put_line('....Drop sequence ' || i.sequence_name);
    BEGIN
        SELECT 'Y' INTO v_sequence_exists
        FROM user_sequences
        WHERE sequence_name = i.sequence_name;

        v_sql_1 := 'DROP SEQUENCE ' || i.sequence_name;
        EXECUTE IMMEDIATE v_sql_1;
        dbms_output.put_line('........Sequence ' || i.sequence_name || ' dropped successfully');
        EXCEPTION
            WHEN no_data_found THEN
            dbms_output.put_line('........Sequence already dropped');
    END;
    END LOOP;
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
salary number
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
subtotal float,
tax float,
total float,
payment varchar(50) NOT NULL,
storeid number REFERENCES store(storeid) NOT NULL
)
/

--SEQUENCES
CREATE SEQUENCE ADDRESS_ID_SEQ
START WITH 7001
INCREMENT BY 1
NOCACHE
NOCYCLE;
/
CREATE SEQUENCE AUTHOR_ID_SEQ
START WITH 2001
INCREMENT BY 1
NOCACHE
NOCYCLE;
/
CREATE SEQUENCE PUBLISHER_ID_SEQ
START WITH 3001
INCREMENT BY 1
NOCACHE
NOCYCLE;
/
CREATE SEQUENCE BOOK_ID_SEQ
START WITH 4001
INCREMENT BY 1
NOCACHE
NOCYCLE;
/
CREATE SEQUENCE STORE_ID_SEQ
START WITH 5001
INCREMENT BY 1
NOCACHE
NOCYCLE;
/
CREATE SEQUENCE EMPLOYEE_ID_SEQ
START WITH 6001
INCREMENT BY 1
NOCACHE
NOCYCLE;
/
CREATE SEQUENCE CUSTOMER_ID_SEQ
START WITH 9001
INCREMENT BY 1
NOCACHE
NOCYCLE;
/
CREATE SEQUENCE ORDERS_ID_SEQ
START WITH 1001
INCREMENT BY 1
NOCACHE
NOCYCLE;
/

--inserting data to author
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'J.K. Rowling');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'Stephen King');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'Chimamanda Ngozi Adichie');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'Margaret Atwood');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'Haruki Murakami');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'Toni Morrison');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'Neil Gaiman');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'David Mitchell');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'George Orwell');
INSERT INTO author VALUES (AUTHOR_ID_SEQ.NEXTVAL, 'Gabriel Garcia Marquez');


--inserting data to publisher
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Penguin Random House');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Simon Schuster');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'HarperCollins');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Macmillan Publishers');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Hachette Livre');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Bloomsbury Publishing');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Scholastic Corporation');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Pearson Education');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Oxford University Press');
INSERT INTO publisher VALUES (PUBLISHER_ID_SEQ.NEXTVAL, 'Cambridge University Press');


--inserting data to book
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'To Kill a Mockingbird', 9780061120084, 'Classic', 1960, 3001, 100);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, '1984', 9780451524935, 'Dystopian', 1949, 3002, 50);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'The Great Gatsby', 9780743273565, 'Classic', 1925, 3003, 20);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'The Catcher in the Rye', 9780316769488, 'Coming of age', 1951, 3004, 30);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'Harry Potter and the Philosophers Stone', 9780747532743, 'Fantasy', 1997, 3005, 80);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'The Lord of the Rings', 9780544003415, 'Fantasy', 1954, 3006, 75);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'The Hunger Games', 9780439023528, 'Dystopian', 2008, 3007, 100);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'Pride and Prejudice', 9780486284736, 'Romance', 1813, 3008, 120);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'The Hitchhikers Guide to the Galaxy', 9780345391803, 'Science Fiction', 1979, 3009, 90);
INSERT INTO book (bookid, title, isbn, genre, publicationyear, publicationid, price) VALUES (BOOK_ID_SEQ.NEXTVAL, 'The Hobbit', 9780547928227, 'Fantasy', 1937, 3010, 50);

--inserting data to bookauthor
INSERT INTO bookauthor VALUES(4001,2001);
INSERT INTO bookauthor VALUES(4002,2002);
INSERT INTO bookauthor VALUES(4003,2003);
INSERT INTO bookauthor VALUES(4004,2004);
INSERT INTO bookauthor VALUES(4005,2005);
INSERT INTO bookauthor VALUES(4006,2006);
INSERT INTO bookauthor VALUES(4007,2007);
INSERT INTO bookauthor VALUES(4008,2008);
INSERT INTO bookauthor VALUES(4009,2009);
INSERT INTO bookauthor VALUES(4010,2010);

--inserting data to address
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1234, 'Elm Street', 'Springfield', 'IL', 62704, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Main Street', 'Smalltown', 'CA', 90210, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9876, 'Oak Lane', 'Greenville', 'NC', 27858, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4321, 'Maple Avenue', 'Burlington', 'VT', 05401, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 555, 'Broadway', 'New York', 'NY', 10012, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 789, 'Cedar Lane', 'Ann Arbor', 'MI', 48104, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 321, 'Willow Road', 'Redwood City', 'CA', 94063, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 456, 'Pine Street', 'Portland', 'ME', 04101, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 987, 'Magnolia Boulevard', 'Burbank', 'CA', 91501, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2468, 'Fifth Avenue', 'Seattle', 'WA', 98101, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Cherry Street', 'Kansas City', 'MO', 64106, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 111, 'Westminster Road', 'Brooklyn', 'NY', 11218, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 222, 'Sycamore Lane', 'Columbus', 'OH', 43215, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 333, 'Birch Street', 'Birmingham', 'AL', 35203, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 444, 'Chestnut Avenue', 'Louisville', 'KY', 40202, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 555, 'Maple Road', 'Oklahoma City', 'OK', 73102, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 666, 'Holly Drive', 'Scottsdale', 'AZ', 85250, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 777, 'Dogwood Street', 'Asheville', 'NC', 28801, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 888, 'Palm Boulevard', 'Miami', 'FL', 33132, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 999, 'Cypress Avenue', 'New Orleans', 'LA', 70112, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1234, 'Elm Street', 'Springfield', 'IL', 62704, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Oak Lane', 'Chicago', 'IL', 60601, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Maple Avenue', 'Naperville', 'IL', 60563, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Cedar Road', 'Arlington Heights', 'IL', 60004, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Pine Street', 'Evanston', 'IL', 60201, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Birch Drive', 'Des Plaines', 'IL', 60016, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Willow Lane', 'Northbrook', 'IL', 60062, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Hickory Avenue', 'Elmhurst', 'IL', 60126, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Spruce Court', 'Schaumburg', 'IL', 60193, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Chestnut Street', 'Peoria', 'IL', 61602, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Larch Drive', 'Glenview', 'IL', 60025, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Aspen Way', 'Downers Grove', 'IL', 60515, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Fir Street', 'Buffalo Grove', 'IL', 60089, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Poplar Lane', 'Wheaton', 'IL', 60187, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Beech Avenue', 'Gurnee', 'IL', 60031, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Cypress Road', 'Vernon Hills', 'IL', 60061, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Juniper Drive', 'Wheeling', 'IL', 60090, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Redwood Court', 'Highland Park', 'IL', 60035, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Dogwood Lane', 'Libertyville', 'IL', 60048, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Mulberry Street', 'Lake Forest', 'IL', 60045, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Cherry Avenue', 'Deerfield', 'IL', 60015, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Basswood Drive', 'Winnetka', 'IL', 60093, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Cottonwood Road', 'Glencoe', 'IL', 60022, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Magnolia Court', 'Kenilworth', 'IL', 60043, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Linden Avenue', 'Northfield', 'IL', 60093, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Hawthorn Lane', 'Lake Bluff', 'IL', 60044, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Spruce Street', 'Glen Ellyn', 'IL', 60137, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Pine Lane', 'Lombard', 'IL', 60148, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Cedar Court', 'Addison', 'IL', 60101, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Elmwood Drive', 'Roselle', 'IL', 60172, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Maple Street', 'Bartlett', 'IL', 60103, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Oakwood Avenue', 'West Chicago', 'IL', 60185, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Willow Court', 'Geneva', 'IL', 60134, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Birch Street', 'St. Charles', 'IL', 60174, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Hickory Drive', 'Batavia', 'IL', 60510, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Sycamore Road', 'Aurora', 'IL', 60505, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Cherry Lane', 'Naperville', 'IL', 60540, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Ash Street', 'Plainfield', 'IL', 60544, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Maplewood Lane', 'Oswego', 'IL', 60543, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Chestnut Drive', 'Yorkville', 'IL', 60560, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Poplar Avenue', 'Sandwich', 'IL', 60548, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Spruce Lane', 'Canton', 'OH', 44708, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Beechwood Drive', 'Akron', 'OH', 44312, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Cedar Avenue', 'Cuyahoga Falls', 'OH', 44221, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Elm Street', 'Fairlawn', 'OH', 44333, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Fir Drive', 'Hudson', 'OH', 44236, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Glenwood Drive', 'Macedonia', 'OH', 44056, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Hilltop Road', 'North Canton', 'OH', 44720, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Ivy Lane', 'Stow', 'OH', 44224, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Juniper Drive', 'Tallmadge', 'OH', 44278, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Kingsley Avenue', 'Twinsburg', 'OH', 44087, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Linden Street', 'Uniontown', 'OH', 44685, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Magnolia Drive', 'Wadsworth', 'OH', 44281, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Oakwood Lane', 'Canal Fulton', 'OH', 44614, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Pine Street', 'Dalton', 'OH', 44618, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Quail Hollow Drive', 'Doylestown', 'OH', 44230, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Riverview Road', 'Kent', 'OH', 44240, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Spruce Avenue', 'Mogadore', 'OH', 44260, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Tulip Lane', 'Navarre', 'OH', 44662, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Vine Street', 'Rittman', 'OH', 44270, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Willow Drive', 'Seville', 'OH', 44273, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Acorn Circle', 'Streetsboro', 'OH', 44241, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Birchwood Avenue', 'Tallmadge', 'OH', 44278, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Chestnut Street', 'Twinsburg', 'OH', 44087, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Dogwood Drive', 'Uniontown', 'OH', 44685, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Evergreen Lane', 'Wadsworth', 'OH', 44281, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Fawn Circle', 'Canal Fulton', 'OH', 44614, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Greenwood Drive', 'Dalton', 'OH', 44618, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Hazelwood Drive', 'Doylestown', 'OH', 44230, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Ironwood Court', 'Kent', 'OH', 44240, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Jasmine Lane', 'Mogadore', 'OH', 44260, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Kendale Drive', 'Navarre', 'OH', 44662, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Lilac Lane', 'Rittman', 'OH', 44270, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Maple Avenue', 'Seville', 'OH', 44273, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Nutmeg Lane', 'Stow', 'OH', 44224, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Oak Avenue', 'Tallmadge', 'OH', 44278, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Pine Ridge Drive', 'Twinsburg', 'OH', 44087, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Quail Ridge Road', 'Uniontown', 'OH', 44685, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Redwood Lane', 'Wadsworth', 'OH', 44281, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Spruce Street', 'Canal Fulton', 'OH', 44614, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Tulip Circle', 'Dalton', 'OH', 44618, 'USA');
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Union Street', 'Doylestown', 'OH', 44230, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Valley View Drive', 'Kent', 'OH', 44240, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Willow Lane', 'Mogadore', 'OH', 44260, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Xenon Drive', 'Navarre', 'OH', 44662, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Yellowstone Road', 'Rittman', 'OH', 44270, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Zinnia Lane', 'Seville', 'OH', 44273, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Amber Drive', 'Stow', 'OH', 44224, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Boulder Drive', 'Tallmadge', 'OH', 44278, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Cedar Street', 'Twinsburg', 'OH', 44087, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Diamond Circle', 'Uniontown', 'OH', 44685, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'Emerald Lane', 'Wadsworth', 'OH', 44281, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 4567, 'Fern Drive', 'Canal Fulton', 'OH', 44614, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 5678, 'Grove Avenue', 'Dalton', 'OH', 44618, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 6789, 'Hickory Lane', 'Doylestown', 'OH', 44230, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 7890, 'Ivy Court', 'Kent', 'OH', 44240, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 8901, 'Juniper Drive', 'Mogadore', 'OH', 44260, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 9012, 'Kingswood Drive', 'Navarre', 'OH', 44662, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 1023, 'Linden Lane', 'Rittman', 'OH', 44270, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 2345, 'Magnolia Drive', 'Seville', 'OH', 44273, 'USA'); 
INSERT INTO address VALUES (ADDRESS_ID_SEQ.NEXTVAL, 3456, 'North Street', 'Stow', 'OH', 44224, 'USA');
