REM: 1. An user is interested to have list of pizza’s in the range of Rs.200-250. Create a view  Pizza_200_250 which keeps the pizza details that has the price in the range of 200 to 250.

CREATE OR REPLACE view Pizza_200_250 AS (
	select * from pizza 
	where unit_price between 200 AND 250
);

select * from Pizza_200_250;

SAVEPOINT Q1;

REM: Insert into view
insert into Pizza_200_250 values (
	'p010', 'Hawaian', 225
);

select * from Pizza_200_250;

Rem: Update View
UPDATE Pizza_200_250
SET unit_price = unit_price * 1.02;

select * from Pizza_200_250;

Rem: Delete from view
delete from Pizza_200_250
where unit_price >= 230;

select * from Pizza_200_250;

ROLLBACK To Q1;

select * from Pizza_200_250;

REM: 2.  Pizza company owner is interested to know the number of pizza types ordered in each order. 
REM: Create a view Pizza_Type_Order that lists the number of pizza types ordered in each order.

CREATE OR REPLACE view Pizza_Type_Order(order_no, num_pizza_types) as (
	select orders.order_no, COUNT(order_list.pizza_id) from orders
	left join order_list on orders.order_no = order_list.order_no
	group by orders.order_no
);

select * from Pizza_Type_Order;

SAVEPOINT Q2;

REM: Insert into view
INSERT into Pizza_Type_Order values (
	'OP900', 12
);

select * from Pizza_Type_Order;

REM: Update view

Update Pizza_Type_Order
SET num_pizza_types = num_pizza_types + 1;

select * from Pizza_Type_Order;

REM: Delete from view
Delete from Pizza_type_order
where num_pizza_types < 2;

select * from Pizza_Type_Order;

ROLLBACK To Q2;

select * from Pizza_Type_Order;

REM: 3. To know about the customers of Spanish pizza, create a view Spanish_Customers that list out 
REM: the customer id, name, order_no of customers who ordered Spanish type

CREATE OR REPLACE VIEW Spanish_Customers AS (
	select distinct cust.cust_id, cust.cust_name, orders.order_no from customer cust
	join orders on cust.cust_id = orders.cust_id
	join order_list on orders.order_no = order_list.order_no
	where order_list.pizza_id = (select pizza_id from pizza where LOWER(pizza_type) = 'spanish')
);

select * from Spanish_Customers;

SAVEPOINT Q3;

REM: Insert into view: (non-primary key preserved table included)
Insert into Spanish_Customers VALUES (
	'c011',
	'Ajay',
	'OP011'
);

select * from Spanish_Customers;

REM: Insert into view: (only primary key preserved table)
Insert into Spanish_Customers(cust_id) VALUES (
	'c011'
);

select * from Spanish_Customers;

REM: Update View
Update Spanish_Customers
SET cust_name = 'Ram'
WHERE cust_id = 'c011';

select * from Spanish_Customers;

REM: Delete from View
Delete from Spanish_Customers
Where cust_id = 'c001';

select * from Spanish_Customers;

ROLLBACK to Q3;

select * from Spanish_Customers;
	