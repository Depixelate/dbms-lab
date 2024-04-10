REM: Dropping Tables
DROP TABLE ORDER_LIST;
DROP TABLE ORDERS;
DROP TABLE PIZZA;
DROP TABLE CUSTOMER;

REM: Creating Tables

REM: Creating Customer 
CREATE TABLE CUSTOMER(
	cust_id CHAR(4) CONSTRAINT cust_id_pk PRIMARY KEY,
	cust_name VARCHAR2(30),
	address VARCHAR2(100),
	phone CHAR(10));

desc Customer;

REM: Creating Pizza
Create TABLE PIZZA(
	pizza_id CHAR(4) CONSTRAINT pizza_id_pk PRIMARY KEY,
	pizza_type VARCHAR(20),
	unit_price NUMBER(6, 2));
desc pizza;

REM: Creating ORDERS
CREATE TABLE ORDERS(
	order_no CHAR(5) CONSTRAINT orders_no_pk PRIMARY KEY,
	cust_id CHAR(4) CONSTRAINT orders_cust_id_fk REFERENCES CUSTOMER(cust_id),
	order_date DATE,
	delv_date DATE);
desc Orders;

REM: CREATING ORDER_LIST
CREATE TABLE ORDER_LIST(
	order_no CHAR(5) CONSTRAINT order_list_order_no_fk REFERENCES ORDERS(order_no),
	pizza_id CHAR(4) CONSTRAINT order_list_pizza_id_fk REFERENCES PIZZA(pizza_id),
	qty NUMBER(6) CONSTRAINT order_list_qty_nn NOT NULL,
	CONSTRAINT ord_list_order_no_pizza_id_pk PRIMARY KEY(order_no, pizza_id));
desc order_list;