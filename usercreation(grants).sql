--EXECUTE FROM DATABASE ADMIN
set SERVEROUTPUT on;
declare
    is_true number;
begin
    select count(*)
    INTO IS_TRUE
    from all_users where username='ADMIN_YASH';
    IF IS_TRUE > 0
    THEN
    EXECUTE IMMEDIATE 'DROP USER ADMIN_YASH CASCADE';
    END IF;
END;
/
create user ADMIN_YASH identified by Dmddadmin12345 DEFAULT TABLESPACE data_ts QUOTA UNLIMITED ON data_ts ;
GRANT CONNECT, RESOURCE TO ADMIN_YASH with admin option; 
--GRANT CONNECT TO ADMIN_YASH;  
grant create view, create procedure, create sequence, CREATE USER, DROP USER to ADMIN_YASH with admin option;
