Rem: Dropping All Tables
DROP TABLE PART_ORDER;

DROP TABLE PART;

DROP TABLE ORD;

DROP TABLE CUST;

DROP TABLE EMP;

DROP TABLE LOC;

Rem: Creating loc
CREATE TABLE LOC(
    PINCODE CHAR(6) CONSTRAINT LOC_PINCODE_PK PRIMARY KEY,
    CITY_NAME VARCHAR(20)
);

desc loc;

Rem: Creating emp
CREATE TABLE EMP(
    EMP_NO CHAR(4) CONSTRAINT EMP_EMP_NO_PK PRIMARY KEY,
    EMP_NAME VARCHAR2(20),
    DOB DATE,
    PINCODE CHAR(6) CONSTRAINT EMP_PINCODE_FK REFERENCES LOC(PINCODE),
    CONSTRAINT EMP_EMP_NO_CHECK CHECK(EMP_NO LIKE 'E%')
);

desc emp;

Rem: Creating cust
CREATE TABLE CUST(
    CUST_NO CHAR(4) CONSTRAINT CUST_CUST_NO_PK PRIMARY KEY,
    CUST_NAME VARCHAR(20),
    STREET_NAME VARCHAR(20),
    PINCODE CHAR(6) CONSTRAINT CUST_PINCODE_FK REFERENCES LOC(PINCODE),
    DOB DATE,
    PHONE_NO CHAR(10) CONSTRAINT CUST_PHONE_NO_UNIQUE UNIQUE,
    CONSTRAINT CUST_CUST_NO_CHECK CHECK(CUST_NO LIKE 'C%')
);

desc cust;

Rem: Creating ord

CREATE TABLE ORD(
    ORDER_NO CHAR(4) CONSTRAINT ORD_ORDER_NO_PK PRIMARY KEY,
    EMP_NO CHAR(4) CONSTRAINT ORD_EMP_NO_FK REFERENCES EMP(EMP_NO),
    CUST_NO CHAR(4) CONSTRAINT ORD_CUST_NO_FK REFERENCES CUST(CUST_NO),
    REC_DATE DATE,
    SHIP_DATE DATE,
    CONSTRAINT ORD_ORDER_NO_CHECK CHECK(ORDER_NO LIKE 'O%'),
    CONSTRAINT ORD_REC_DATE_SHIP_DATE_LESS CHECK(REC_DATE < SHIP_DATE)
);

desc ord;

Rem: Creating part

CREATE TABLE PART(
    PART_NO CHAR(4) CONSTRAINT PART_PART_NO_PK PRIMARY KEY,
    PART_NAME VARCHAR(20),
    PRICE NUMBER(8, 2) CONSTRAINT PART_PRICE_NN NOT NULL,
    QUANTITY NUMBER(6),
    CONSTRAINT PART_PART_NO_CHECK CHECK(PART_NO LIKE 'P%')
);

desc part;

Rem: creating part_order

CREATE TABLE PART_ORDER(
    ORDER_NO CHAR(4) CONSTRAINT PART_ORDER_ORDER_NO_FK REFERENCES ORD(ORDER_NO),
    PART_NO CHAR(4) CONSTRAINT PART_ORDER_PART_NO_FK REFERENCES PART(PART_NO),
    QUANTITY NUMBER(6) CONSTRAINT PART_ORDER_QUANTITY_CHECK CHECK(QUANTITY > 0),
    CONSTRAINT PART_ORDER_ORDER_NO_PART_NO_PK PRIMARY KEY(ORDER_NO, PART_NO)
);

desc part_order;


Rem: Inserting 2 good rows into loc, then one bad row per constraint.
INSERT INTO LOC VALUES (
    '603103',
    'Chennai'
);

INSERT INTO LOC VALUES (
    '110001',
    'Delhi'
);

select * from loc;

Rem: uniqueness constraint.
INSERT INTO LOC VALUES (
    '603103',
    'Mumbai'
);

Rem: NULL constraint
INSERT INTO LOC VALUES (
    NULL,
    'Mumbai'
);

Rem: Inserting 2 good rows, 1 bad row per constraint into EMP

insert into emp values (
    'E001',
    'Sundaresh G Karthick',
    DATE '1996-01-01',
    '603103'
);

insert into emp values (
    'E002',
    'Tharunithi',
    DATE '1975-02-03',
    '110001'
);

select * from emp;

Rem: Not null constraint
insert into emp values (
    NULL,
    'Ram',
    DATE '1999-01-01',
    '110001'
);

Rem: unique constraint
insert into emp values (
    'E001',
    'Shaun',
    DATE '2100-01-01',
    '603103'
);

Rem: check constraint
insert into emp values (
    '2012',
    'Paul',
    DATE '1870-01-01',
    '110001'
);

Rem: pincode doesn't match any given in loc table.
insert into emp values (
    'E003',
    'Tim',
    DATE '1995-02-02',
    '231065'
);

Rem: inserting two good rows, 1 bad row per constraint for cust.
insert into cust values(
    'C001',
    'Shudhesh',
    'OMR',
    '603103',
    DATE '2004-07-06',
    '9597978293'
);

insert into cust values(
    'C002',
    'Sukessh',
    'DLF Garden City Road',
    '110001',
    DATE '2001-01-01',
    '9944251843'
);

select * from cust;

Rem: inserting NULL into primary KEY
insert into cust values(
    NULL,
    'Sukessh',
    'DLF Garden City Road',
    '110001',
    DATE '2001-01-01',
    '9944251844'
);

Rem: insert duplicate primary KEY
insert into cust values(
    'C001',
    'Sukessh',
    'DLF Garden City Road',
    '110001',
    DATE '2001-01-01',
    '9944251845'
);

Rem: insert cust id that doesn't follow format
insert into cust values(
    '0003',
    'Sukessh',
    'DLF Garden City Road',
    '110001',
    DATE '2001-01-01',
    '9944251846'
);

Rem: insert pincode that doesn't exist in loc
insert into cust values(
    'C003',
    'Sukessh',
    'DLF Garden City Road',
    '110002',
    DATE '2001-01-01',
    '9944251847'
);


Rem: insert repeated phone no.
insert into cust values(
    'C003',
    'Sukessh',
    'DLF Garden City Road',
    '110001',
    DATE '2001-01-01',
    '9944251843'
);

Rem: insert 2 good rows, 1 bad row per constraint for the table ORD
insert into ord values(
    'O001',
    'E001',
    'C001',
    DATE '2024-01-01',
    DATE '2024-02-01'
);

insert into ord values(
    'O002',
    'E002',
    'C002',
    DATE '2023-12-01',
    DATE '2024-01-05'
);

select * from ord;

Rem: insert NULL as primary KEY
insert into ord values(
    NULL,
    'E002',
    'C002',
    DATE '2023-12-01',
    DATE '2024-01-05'
);

Rem: insert duplicate as primary KEY
insert into ord values(
    'O001',
    'E002',
    'C002',
    DATE '2023-12-01',
    DATE '2024-01-05'
);

Rem: insert primary key that doesn't match format
insert into ord values(
    'U001',
    'E002',
    'C002',
    DATE '2023-12-01',
    DATE '2024-01-05'
);

Rem: employee of order's employee id not present
insert into ord values(
    'O003',
    'E005',
    'C002',
    DATE '2023-12-01',
    DATE '2024-01-05'
);

Rem: customer of order's customer id not present
insert into ord values(
    'O003',
    'E002',
    'C005',
    DATE '2023-12-01',
    DATE '2024-01-05'
);

Rem: set Recieved date greater than ship date.
insert into ord values(
    'O003',
    'E002',
    'C002',
    DATE '2024-12-01',
    DATE '2023-01-05'
);

Rem: Enter 2 good rows for the table, then one bad row per constraint.
insert into PART values(
    'P001',
    'Pliers',
    10.05,
    100
);

insert into PART values(
    'P002',
    'Saw',
    20.05,
    100
);

select * from part;

Rem: PK NON-Null CONSTRAINT
insert into PART values(
    NULL,
    'Saw',
    20.05,
    100
);

Rem: PK Unique CONSTRAINT
insert into PART values(
    'P001',
    'Saw',
    20.05,
    100
);

Rem: PK Format constraint
insert into PART values(
    '0003',
    'Saw',
    20.05,
    100
);

Rem: PRICE NON-NULL CONSTRAINT
insert into PART values(
    'P003',
    'Saw',
    NULL,
    100
);

Rem: Insert 2 good rows into PART_ORDER, then 1 bad row per CONSTRAINT
insert into part_order values(
    'O001',
    'P001',
    50
);

insert into part_order values(
    'O002',
    'P002',
    20
);

select * from part_order;

Rem: violate PK non-null CONSTRAINT
insert into part_order values(
    NULL,
    'P001',
    30
);

Rem: violate PK uniqueness CONSTRAINT
insert into part_order values(
    'O002',
    'P002',
    50
);

Rem: violate order_no fk CONSTRAINT
insert into part_order values(
    'O003',
    'P002',
    25
);

Rem: violate part_no pk CONSTRAINT
insert into part_order values(
    'O002',
    'P003',
    75
);

Rem: violate quantity > 0 CONSTRAINT
insert into part_order values(
    'O002',
    'P001',
    0
);

Rem: It is identified that the following attributes are to be included in respective relations:Parts (reorder level), Employees (hiredate)
desc part;
alter table part add reorder_level Number(6);
desc part;

Rem:. It is identified that the following attributes are to be included in respective relations:Parts(reorder level), Employees (hiredate)
desc emp;
alter table emp add hiredate DATE;
desc emp;

Rem: The width of a customer name is not adequate for most of the customers.
desc CUST;
insert into cust values(
    'C004',
    'Sundaresh Ganesan Karthick',
    'Broadway',
    '603103',
    DATE '2004-01-01',
    1234567890
);
select * from cust;
alter table cust modify cust_name varchar(100);
desc CUST;
insert into cust values(
    'C004',
    'Sundaresh Ganesan Karthick',
    'Broadway',
    '603103',
    DATE '2004-01-01',
    1234567890
);
select * from cust;

Rem: The date-of-birth of a customer can be addressed later / removed from the schema.
desc cust;
alter table cust drop column dob;
desc cust;

Rem: Make it mandatory that the order has a recieved dated

Rem: Note that we can't add a NOT NULL constraint as a table level constraint,
Rem: Not NULL is always a column level constraint.
Rem: So we have to modify the col we want to add the NOT NULL constraint to 
Rem: In order to add the constraint.
    
Rem: desc ord;
insert into ord values ('O004', 'E001', 'C001', NULL, DATE '2024-02-01');
select * from ord;
delete from ord where order_no = 'O004';
alter table ord MODIFY (rec_date NOT NULL);
Rem: desc ord;
insert into ord values ('O004', 'E001', 'C001', NULL, DATE '2024-02-01');

Rem: A customer may cancel an order or ordered part(s) may not be available in a stock. Hence on removing the details of the order, ensure that all the corresponding details are also deleted
    
Rem: Note that you don't set ON DELETE UPDATE, ON DELETE CASCADE, etc. on the primary key and have it apply to every foreign key when the primary key gets updated/deleted.
Rem: Rather, you set the constraint of ON UPDATE, ON DELETE on the foreign key itself.
Rem: By doing this, you can specify different behaviours for different foreign keys. 

Rem: Also Note that we can't modify constraints, only drop and recreate them.

Rem: Note that upto now we were setting foreign keys as column-level constraints, 
Rem: where you could omit FOREIGN KEY(<col_name>)
Rem: Now that we have to add it as a table-level constraint, 
Rem: we have to specify add constraint <name> FOREIGN KEY(<col_name>) references <other_table>(<other_table_pk);

delete from ord where order_no = 'O002';

desc part_order;
alter table part_order drop constraint part_order_order_no_fk;
alter table part_order add constraint part_order_order_no_fk FOREIGN KEY(order_no) References ORD(order_no) ON DELETE CASCADE;
desc part_order;

select * from ord;
select * from PART_ORDER;

delete from ord where order_no = 'O002';

select * from ord;
select * from part_order;
