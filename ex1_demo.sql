Rem: Dropping All Tables
drop table part_order;
drop table part;
drop table ord;
drop table cust;
drop table emp;
drop table loc;


Rem: Creating loc
create table loc(
  pincode char(6) constraint loc_pincode_pk primary key,
  city_name varchar(20));

desc loc

Rem: Creating emp
create table emp(
  emp_no char(4) constraint emp_emp_no_pk PRIMARY KEY,
  emp_name varchar2(20),
  dob date,
  pincode char(6) constraint emp_pincode_fk references loc(pincode),
  constraint emp_emp_no_check check(emp_no like 'E%'));

desc emp

Rem: Creating cust
create table cust(
  cust_no char(4) constraint cust_cust_no_pk primary key,
  cust_name varchar(20),
  street_name varchar(20),
  pincode char(6) constraint cust_pincode_fk references loc(pincode),
  dob date,
  phone_no char(10) constraint cust_phone_no_unique unique,
  constraint cust_cust_no_check check(cust_no like 'C%'));

desc cust

Rem: Creating ord

create table ord(
  order_no char(4) constraint ord_order_no_pk primary key,
  emp_no char(4) constraint ord_emp_no_fk references emp(emp_no),
  cust_no char(4) constraint ord_cust_no_fk references cust(cust_no),
  rec_date date,
  ship_date date,
  constraint ord_order_no_check check(order_no like 'O%'),
  constraint ord_rec_date_ship_date_less check(rec_date < ship_date));

desc ord

Rem: Creating part

create table part(
  part_no char(4) constraint part_part_no_pk primary key,
  part_name varchar(20),
  price number(8, 2) constraint part_price_nn NOT NULL,
  quantity number(6),
  constraint part_part_no_check check(part_no like 'P%'));


desc part

Rem: creating part_order

create table part_order(
  order_no char(4) constraint part_order_order_no_fk references ord(order_no),
  part_no char(4) constraint part_order_part_no_fk references part(part_no),
  quantity number(6) constraint part_order_quantity_check check(quantity > 0),
  constraint part_order_order_no_part_no_pk primary key(order_no, part_no));

desc part_order