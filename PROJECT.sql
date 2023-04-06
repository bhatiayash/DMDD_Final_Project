
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