
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

--package to handle and drop users
SET SERVEROUTPUT ON;
create or replace PACKAGE HANDLE_USER AS 

   
  procedure drop_user(
    IN_username VARCHAR
    );


END HANDLE_USER;
/
create or replace PACKAGE BODY HANDLE_USER AS 

   
  procedure drop_user(
    IN_username VARCHAR
    )
  as 
  IS_TRUE  number;
sql_stmt    VARCHAR2(200);
Invalid_username exception;
user_not_found exception ;
v_user_name all_users.username%type;
cursor c_all_users is
    select username from all_users;
BEGIN
if length(IN_username) <= 0
        then 
            raise Invalid_username;
    end if;

    IS_TRUE := 0;

    OPEN c_all_users; 
   LOOP 
   FETCH c_all_users into v_user_name; 
      EXIT WHEN c_all_users%notfound; 
      
    IF (
    trim(lower(v_user_name)) = trim(lower(IN_username)) 
      )
    then 
    sql_stmt := 'DROP user '||IN_username;
    dbms_output.put_line(sql_stmt );
    EXECUTE IMMEDIATE sql_stmt;    
    dbms_output.put_line(IN_username||  ' user is dropped.' );
    IS_TRUE := 1;
    END IF;
    

   END LOOP; 

   CLOSE c_all_users; 

   if IS_TRUE = 0 then raise user_not_found ;
   end if;

commit;

EXCEPTION
when Invalid_username
then dbms_output.put_line('Please enter correct username');
when user_not_found
then dbms_output.put_line( IN_username || ' not found');
when others
then dbms_output.put_line(sqlerrm);
END drop_user;

END HANDLE_USER;
/
--DROP USERS
EXEC HANDLE_USER.drop_user('CUSTOMER_USER');
EXEC HANDLE_USER.drop_user('EMPLOYEE_USER');
/
--procedure to insert new customer
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE add_new_customer(
IN_FIRSTNAME IN CUSTOMER.FIRSTNAME%type,
IN_LASTNAME IN CUSTOMER.LASTNAME%type,
IN_GENDER IN CUSTOMER.GENDER%type,
IN_ADDRESSID IN CUSTOMER.ADDRESSID%type,
IN_EMAIL IN CUSTOMER.EMAIL%type
)
AS
invalid_FIRSTNAME exception;
invalid_LASTNAME exception;
invalid_GENDER exception;
invalid_ADDRESSID exception;
invalid_EMAIL exception;
BEGIN

if (IN_FIRSTNAME) IS NULL
    then
        raise invalid_FIRSTNAME;
    elsif (IN_LASTNAME) IS NULL
        then
        raise invalid_LASTNAME;
    elsif (IN_GENDER) IS NULL
        then
        raise invalid_GENDER;
    elsif length(IN_ADDRESSID) <=0 or (IN_ADDRESSID is null)
        then
        raise invalid_ADDRESSID;
    elsif (IN_EMAIL) IS NULL
        then
        raise invalid_EMAIL;
end if;

insert into customer(
customerid,
firstname,
lastname,
gender,
addressid,
email
)
values(
customer_id_seq.nextval,
IN_FIRSTNAME,
IN_LASTNAME,
IN_GENDER,
IN_ADDRESSID,
IN_EMAIL
);
COMMIT;
EXCEPTION
WHEN invalid_FIRSTNAME
THEN dbms_output.put_line('Please enter correct customer first name');
WHEN invalid_LASTNAME
THEN dbms_output.put_line('Please enter correct customer last name');
WHEN invalid_GENDER
THEN dbms_output.put_line('Please enter correct customer gender');
WHEN invalid_ADDRESSID
THEN dbms_output.put_line('Please enter correct customer addressid');
WHEN invalid_EMAIL
THEN dbms_output.put_line('Please enter correct customer email');
WHEN OTHERS
THEN dbms_output.put_line(sqlerrm);
END add_new_customer;
/

--procedure to insert new author
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE add_new_author(
IN_AUTHORNAME IN AUTHOR.AUTHORNAME%type
)
AS
invalid_AUTHORNAME exception;
BEGIN

if (IN_AUTHORNAME) IS NULL
    then
        raise invalid_AUTHORNAME;
end if;

insert into AUTHOR(
AUTHORID,
AUTHORNAME
)
values(
author_id_seq.nextval,
IN_AUTHORNAME
);
COMMIT;
EXCEPTION
WHEN invalid_AUTHORNAME
THEN dbms_output.put_line('Please enter correct author name');
WHEN OTHERS
THEN dbms_output.put_line(sqlerrm);
END add_new_author;
/

--procedure to insert new book
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE add_new_book(
IN_TITLE IN BOOK.TITLE%type,
IN_ISBN IN BOOK.ISBN%type,
IN_GENRE IN BOOK.GENRE%type,
IN_PUBLICATIONYEAR IN BOOK.PUBLICATIONYEAR%type,
IN_PUBLICATIONID IN BOOK.PUBLICATIONID%type,
IN_PRICE IN BOOK.PRICE%type
)
AS
invalid_TITLE exception;
invalid_ISBN exception;
invalid_GENRE exception;
invalid_PUBLICATIONYEAR exception;
invalid_PUBLICATIONID exception;
invalid_PRICE exception;
BEGIN

if (IN_TITLE) IS NULL
    then
        raise invalid_TITLE;
    elsif (IN_ISBN) IS NULL OR (IN_ISBN) <= 0
        then
        raise invalid_ISBN;
    elsif (IN_GENRE) IS NULL
        then
        raise invalid_GENRE;
    elsif (IN_PUBLICATIONYEAR) is null OR (IN_PUBLICATIONYEAR) <= 0
        then
        raise invalid_PUBLICATIONYEAR;
    elsif (IN_PUBLICATIONID) IS NULL OR (IN_PUBLICATIONID) <= 0
        then
        raise invalid_PUBLICATIONID;
    elsif (IN_PRICE) IS NULL OR (IN_PRICE) <= 0
        then
        raise invalid_PRICE;
end if;

insert into book(
bookid,
title,
isbn,
genre,
publicationyear,
publicationid,
price
)
values(
book_id_seq.nextval,
IN_TITLE,
IN_ISBN,
IN_GENRE,
IN_PUBLICATIONYEAR,
IN_PUBLICATIONID,
IN_PRICE
);
COMMIT;
EXCEPTION
WHEN invalid_TITLE
THEN dbms_output.put_line('Please enter correct title, it cannot be null');
WHEN invalid_ISBN
THEN dbms_output.put_line('Please enter correct ISBN, it cannot be null');
WHEN invalid_GENRE
THEN dbms_output.put_line('Please enter correct Genre, it cannot be null');
WHEN invalid_PUBLICATIONYEAR
THEN dbms_output.put_line('Please enter correct publication year');
WHEN invalid_PUBLICATIONID
THEN dbms_output.put_line('Please enter correct publicationid');
WHEN invalid_PRICE
THEN dbms_output.put_line('Please enter correct price');
WHEN OTHERS
THEN dbms_output.put_line(sqlerrm);
END add_new_book;
/

--procedure to insert new publisher
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE add_new_publisher(
IN_PUBLISHERNAME IN PUBLISHER.PUBLISHERNAME%type
)
AS
invalid_PUBLISHERNAME exception;
BEGIN

if (IN_PUBLISHERNAME) IS NULL
    then
        raise invalid_PUBLISHERNAME;
end if;

insert into PUBLISHER(
PUBLISHERID,
PUBLISHERNAME
)
values(
publisher_id_seq.nextval,
IN_PUBLISHERNAME
);
COMMIT;
EXCEPTION
WHEN invalid_PUBLISHERNAME
THEN dbms_output.put_line('Please enter correct publisher name, it cannot be null');
WHEN OTHERS
THEN dbms_output.put_line(sqlerrm);
END add_new_publisher;
/


--procedure to insert new store
SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE add_new_store(
IN_ADDRESSID IN STORE.ADDRESSID%type,
IN_PHONENUMBER IN STORE.PHONENUMBER%type
)
AS
invalid_ADDRESSID exception;
invalid_PHONENUMBER exception;
BEGIN

if (IN_ADDRESSID) IS NULL OR (IN_ADDRESSID) <= 0
    then
        raise invalid_ADDRESSID;
    elsif (IN_PHONENUMBER) IS NULL OR (IN_PHONENUMBER) <= 0
    then
        raise invalid_PHONENUMBER;
end if;

insert into STORE(
STOREID,
ADDRESSID,
PHONENUMBER
)
values(
store_id_seq.nextval,
IN_ADDRESSID,
IN_PHONENUMBER
);
COMMIT;
EXCEPTION
WHEN invalid_ADDRESSID
THEN dbms_output.put_line('Please enter correct addressid');
WHEN invalid_PHONENUMBER
THEN dbms_output.put_line('Please enter correct phonenumber');
WHEN OTHERS
THEN dbms_output.put_line(sqlerrm);
END add_new_store;
/

--TRIGGER to calculate the subtotal, tax and total of the order before inserting  the record
CREATE OR REPLACE TRIGGER update_order_total
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF :NEW.subtotal IS NULL THEN
    :NEW.subtotal := :NEW.price * :NEW.quantity;
    END IF;
    IF :NEW.tax IS NULL THEN
    :NEW.tax := 0.1 * :NEW.price * :NEW.quantity;
    END IF;
    IF :NEW.total IS NULL THEN
    :NEW.total := 1.1 * :NEW.price * :NEW.quantity;
    END IF;
END;
/

--Trigger to set default salary of an employee
CREATE OR REPLACE TRIGGER set_default_salary
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    IF :NEW.salary IS NULL THEN
        :NEW.salary := 50000;
    END IF;
END;
/
--Trigger to prevent deletion of publisher if any book is associated with it
CREATE OR REPLACE TRIGGER prevent_publisher_delete
BEFORE DELETE ON publisher
FOR EACH ROW
DECLARE
    cnt NUMBER;
BEGIN
SELECT COUNT(*) INTO cnt FROM book WHERE publicationid = :OLD.publisherid;
IF cnt > 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Cannot delete publisher with associated books');
END IF;
END;
/
--Function to display number of books available in a store for a single bookid
CREATE OR REPLACE FUNCTION get_book_quantity (p_store_id IN NUMBER, p_book_id IN NUMBER) RETURN NUMBER
IS
    v_quantity Inventory.Quantity%TYPE;
BEGIN
    SELECT Quantity INTO v_quantity FROM Inventory
    WHERE StoreID = p_store_id AND BookID = p_book_id;
    RETURN v_quantity;
END get_book_quantity;
/

--function to display book price
CREATE OR REPLACE FUNCTION get_book_price (p_book_id IN NUMBER) RETURN NUMBER
IS
    v_price book.price%TYPE;
BEGIN
    SELECT Price INTO v_price FROM BOOK
    WHERE BookID = p_book_id;
    RETURN v_price;
END get_book_price;
/

--procedure to insert a new order
CREATE OR REPLACE PROCEDURE add_order (
    p_customerid in NUMBER,
    p_bookid in NUMBER,
    p_quantity in NUMBER,
    p_payment in VARCHAR2,
    p_storeid in NUMBER
)
AS
invalid_customerid exception;
invalid_bookid exception;
invalid_quantity exception;
invalid_payment exception;
invalid_storeid exception;
invalid_quantity1 exception;
BEGIN

if (p_customerid) is null OR (p_customerid) <= 0
    then   
        raise invalid_customerid;
    elsif (p_bookid) is null OR (p_bookid) <= 0
    then
        raise invalid_bookid;
    elsif (p_quantity) is null OR (p_quantity) <=0
    then
        raise invalid_quantity;
    elsif (p_payment) is null
    then
        raise invalid_payment;
    elsif (p_storeid) is null OR (p_storeid) <= 0
    then
        raise invalid_storeid;
    ELSIF (p_quantity) > (get_book_quantity(p_storeid, p_bookid))
    THEN
        RAISE invalid_quantity1;
end if;

    INSERT INTO orders (orderid, customerid, bookid, quantity, price, payment, storeid)
    VALUES (orders_id_seq.NEXTVAL, p_customerid, p_bookid,p_quantity, get_book_price(p_bookid), p_payment, p_storeid);
    COMMIT;
EXCEPTION
WHEN invalid_customerid
THEN dbms_output.put_line('Please enter correct customerid');
WHEN invalid_bookid
THEN dbms_output.put_line('Please enter correct bookid');
WHEN invalid_quantity
THEN dbms_output.put_line('Please enter correct quantity');
WHEN invalid_payment
THEN dbms_output.put_line('Please enter correct payment');
WHEN invalid_storeid
THEN dbms_output.put_line('Please enter correct storeid');
WHEN invalid_quantity1
THEN dbms_output.put_line('Number of books not available in store');
END add_order;
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

--inserting data to store
INSERT INTO store (storeid, addressid, phonenumber) VALUES (STORE_ID_SEQ.NEXTVAL, 7001, 8573131234);
INSERT INTO store (storeid, addressid, phonenumber) VALUES (STORE_ID_SEQ.NEXTVAL, 7002, 6175551212);
INSERT INTO store (storeid, addressid, phonenumber) VALUES (STORE_ID_SEQ.NEXTVAL, 7003, 2125555555);
INSERT INTO store (storeid, addressid, phonenumber) VALUES (STORE_ID_SEQ.NEXTVAL, 7004, 3125555555);
INSERT INTO store (storeid, addressid, phonenumber) VALUES (STORE_ID_SEQ.NEXTVAL, 7005, 4155555555);


--inserting data to employee
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (EMPLOYEE_ID_SEQ.NEXTVAL, 5001, 'Steven', 'Ponting', 7006, 90000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (EMPLOYEE_ID_SEQ.NEXTVAL, 5002, 'Emily', 'Wong', 7007, 80000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (EMPLOYEE_ID_SEQ.NEXTVAL, 5003, 'John', 'Smith', 7008, 70000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (EMPLOYEE_ID_SEQ.NEXTVAL, 5004, 'Sarah', 'Johnson', 7009, 85000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (EMPLOYEE_ID_SEQ.NEXTVAL, 5005, 'Mike', 'Davis', 7010, 75000);
INSERT INTO employee (employeeid, storeid, employeefirstname, employeelastname, addressid, salary) VALUES (EMPLOYEE_ID_SEQ.NEXTVAL, 5001, 'Zach', 'Clinton', 7011, 55000);


--inserting data to inventory
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4001, 50);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4002, 25);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4003, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4004, 75);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4005, 10);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4006, 20);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4007, 45);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4008, 60);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4009, 80);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5001, 4010, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4001, 50);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4002, 25);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4003, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4004, 75);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4005, 10);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4006, 20);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4007, 45);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4008, 60);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4009, 80);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5002, 4010, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4001, 50);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4002, 25);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4003, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4004, 75);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4005, 10);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4006, 20);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4007, 45);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4008, 60);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4009, 80);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5003, 4010, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4001, 50);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4002, 25);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4003, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4004, 75);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4005, 10);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4006, 20);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4007, 45);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4008, 60);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4009, 80);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5004, 4010, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4001, 50);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4002, 25);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4003, 100);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4004, 75);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4005, 10);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4006, 20);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4007, 45);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4008, 60);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4009, 80);
INSERT INTO inventory (storeid, bookid, quantity) VALUES (5005, 4010, 100);

--inserting data to customer
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'Rick', 'Hayden', 'Male', 7011, 'rickhayden@gmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'Sarah', 'Lee', 'Female', 7012, 'sarahlee@hotmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'John', 'Doe', 'Male', 7013, 'johndoe@yahoo.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'Emily', 'Chen', 'Female', 7014, 'emilychen@gmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'Mike', 'Nguyen', 'Male', 7015, 'mikenguyen@gmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'Avery', 'Parker', 'Male', 7016, 'averyparker@yahoo.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'Grace', 'Kim', 'Female', 7017, 'gracekim@gmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'Jacob', 'Garcia', 'Male', 7018, 'jacobgarcia@hotmail.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'Lily', 'Tran', 'Female', 7019, 'lilytran@yahoo.com');
INSERT INTO customer (customerid, firstname, lastname, gender, addressid, email) VALUES (CUSTOMER_ID_SEQ.NEXTVAL, 'David', 'Wu', 'Male', 7020, 'davidwu@gmail.com');

--inserting data to orders

INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9001, 4001, 2, 100, '1234567890',5001);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9002, 4002, 3, 50, '2345678901',5002);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9003, 4003, 4, 20, '3456789012',5003);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9004, 4004, 5, 30, '4567890123',5004);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9005, 4005, 6, 80, '5678901234',5005);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9001, 4004, 3, 30, '5432101234',5001);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9009, 4001, 1, 100, '1234567890', 5001);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9001, 4002, 3, 50, '0987654321', 5002);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9002, 4003, 2, 20, '1357908642', 5003);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9003, 4004, 1, 30, '2468013579', 5004);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9004, 4005, 2, 80, '9876543210', 5005);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9005, 4006, 1, 75, '0123456789', 5001);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9006, 4007, 3, 100, '5678901234', 5002);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9007, 4008, 2, 120, '3216549870', 5003);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9008, 4009, 1, 90, '0987123456', 5004);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9009, 4010, 2, 50, '5432167890', 5005);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9010, 4001, 3, 100, '4321098765', 5001);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9001, 4002, 2, 50, '0987654321', 5002);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9001, 4003, 1, 20, '2468013579', 5003);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9002, 4004, 2, 30, '5678901234', 5004);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9003, 4005, 3, 80, '0123456789', 5005);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9004, 4006, 2, 75, '0987123456', 5001);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9005, 4007, 1, 100, '5432167890', 5002);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9006, 4008, 2, 120, '4321098765', 5003);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9007, 4009, 3, 90, '3216549870', 5004);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9008, 4010, 2, 50, '0123456789', 5005);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9009, 4001, 1, 100, '9876543210', 5001);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9010, 4002, 2, 50, '1234567890', 5002);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9003, 4003, 3, 20, '5678901234', 5003);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9001, 4004, 2, 30, '3216549870', 5004);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9002, 4005, 1, 80, '0987123456', 5005);
INSERT INTO orders(orderid, customerid, bookid, quantity, price, payment, storeid) VALUES (ORDERS_ID_SEQ.NEXTVAL, 9003, 4006, 2, 75, '5432167890', 5001);

/
--view for displaying book details (author, title, publisher and price)
CREATE OR REPLACE VIEW book_view AS
SELECT a.authorname, p.publishername, b.title, b.price
FROM author a
JOIN bookauthor ba ON a.authorid = ba.authorid
JOIN book b ON ba.bookid = b.bookid
JOIN publisher p ON b.publicationid = p.publisherid;

--View for displaying nuumber of books available in the store
CREATE OR REPLACE VIEW books_available AS
SELECT storeid, SUM(quantity) AS NUM_BOOKS_AVAILABLE
FROM inventory
GROUP BY storeid
ORDER BY storeid;

--view for displaying order summary
CREATE OR REPLACE VIEW order_details AS
SELECT
  orders.orderid,
  orders.total,
  orders.customerid,
  customer.firstname,
  customer.lastname,
  author.authorname,
  book.title
FROM
  orders
  JOIN customer ON orders.customerid = customer.customerid
  JOIN book ON orders.bookid = book.bookid
  JOIN bookauthor ON book.bookid = bookauthor.bookid
  JOIN author ON bookauthor.authorid = author.authorid
ORDER BY orderid;

--view for displaying number of employees at each store
CREATE OR REPLACE VIEW employee_count AS
SELECT storeid, COUNT(*) AS num_employees
FROM employee
GROUP BY storeid
ORDER BY storeid;
/

--View for higest selling books
CREATE OR REPLACE VIEW highest_selling_books AS
SELECT b.bookid, b.title, SUM(o.quantity) AS total_sales
FROM book b
JOIN orders o ON b.bookid = o.bookid
GROUP BY b.bookid, b.title
ORDER BY total_sales DESC;
/

--view to
CREATE OR REPLACE VIEW v_store_sales AS
SELECT storeid, SUM(quantity) AS total_sales
FROM orders
GROUP BY storeid
order by total_sales desc;
/

--View to
CREATE OR REPLACE VIEW v_most_books_sold_per_store AS
SELECT storeid, bookid, quantity
FROM (
    SELECT storeid, bookid, quantity,
        ROW_NUMBER() OVER (PARTITION BY storeid ORDER BY quantity DESC) AS rn
    FROM orders
) t
WHERE rn = 1;
/

--Get the list of all authors who have written at least one book in every genre
CREATE OR REPLACE VIEW author_every_genre AS
SELECT a.authorid, a.authorname
FROM author a
WHERE NOT EXISTS (
    SELECT DISTINCT b.genre
    FROM book b
    WHERE b.genre NOT IN (
        SELECT DISTINCT b2.genre
        FROM book b2
        JOIN bookauthor ba ON b2.bookid = ba.bookid
        WHERE ba.authorid = a.authorid
    )
);
/

--view to display number of orders from each store
CREATE OR REPLACE VIEW num_of_orders_each_store AS
SELECT store.storeid, COUNT(orders.orderid) as num_orders
FROM store
JOIN orders ON store.storeid = orders.storeid
GROUP BY store.storeid
ORDER BY num_orders DESC;
/

--view to display maximum amount spent by all customers
CREATE OR REPLACE VIEW highest_total_spend AS
SELECT customer.customerid, customer.firstname, customer.lastname, SUM(orders.total) as total_spent
FROM customer
JOIN orders ON orders.customerid = customer.customerid
GROUP BY customer.customerid, customer.firstname, customer.lastname
ORDER BY total_spent DESC;
/

--View to display top selling author
CREATE OR REPLACE VIEW top_selling_author AS
SELECT authorname, SUM(quantity) as total_sold
FROM author
JOIN bookauthor ON author.authorid = bookauthor.authorid
JOIN book ON book.bookid = bookauthor.bookid
JOIN orders ON orders.bookid = book.bookid
GROUP BY authorname
ORDER BY total_sold DESC;
/
