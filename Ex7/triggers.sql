SET SERVEROUTPUT ON;
SET ECHO ON;

REM: 1. Ensure that the pizza can be delivered on same day or on the next day only.
REM: Creating trigger
CREATE OR REPLACE TRIGGER same_or_next_delv_date
    BEFORE INSERT OR UPDATE OF order_date, delv_date
    ON ORDERS
    FOR EACH ROW
    WHEN (NEW.delv_date - NEW.order_date >=2 OR NEW.delv_date - NEW.order_date < 0)
BEGIN
    raise_application_error(-20001, 'Delivery Date is either before or more than 1 day after the order date');
END;
/

REM: Testing trigger
REM: valid insert
savepoint A;
select * from orders;

insert into orders values (
    'OP950',
    'c001',
    DATE '2024-09-05',
    DATE '2024-09-05'
);

select * from orders;

REM: invalid insert

insert into orders values (
    'OP960',
    'c001',
    DATE '2024-09-05',
    DATE '2024-09-07'
);


select * from orders;

REM: valid UPDATE

update orders
set delv_date = order_date
WHERE delv_date > order_date;

select * from orders;

REM: invalid UPDATE

update orders
set delv_date = order_date - 1;

select * from orders;

ROLLBACK to A;

REM: 2. Update the total_amt in ORDERS while entering an order in ORDER_LIST

REM: Adding total_amt to orders

alter table orders ADD total_amt NUMBER;
update orders outer_ord
set total_amt = (
    select SUM(p.unit_price * ol.qty) from orders o
    join order_list ol on o.order_no = ol.order_no
    join pizza p on ol.pizza_id = p.pizza_id
    where o.order_no = outer_ord.order_no
);

REM: Declaring TRIGGER
CREATE OR REPLACE TRIGGER update_total_amt
    AFTER INSERT OR DELETE OR UPDATE OF pizza_id, qty ON order_list
-- DECLARE
--     new_total_amt orders.total_amt%TYPE;
--     o_id orders.order_no%TYPE;
BEGIN
    -- CASE
    --     WHEN INSERTING OR UPDATING THEN
    --         o_id := :NEW.order_no;
    --     WHEN DELETING THEN
    --         o_id := :OLD.order_no;
    -- END CASE;
    update orders outer_ord
    set total_amt = (
        select SUM(p.unit_price * ol.qty) from orders o
        join order_list ol on o.order_no = ol.order_no
        join pizza p on ol.pizza_id = p.pizza_id
        where o.order_no = outer_ord.order_no
    );
END;
/ 

REM: testing trigger

SAVEPOINT B;

select * from orders;
select * from order_list;
select * from pizza;

REM: Test insert

INSERT into order_list values (
    'OP200',
    'p002',
    3
);

select * from orders;
select * from order_list;
select * from pizza;

REM: Test update

UPDATE order_list
set pizza_id = 'p005',
    qty = 4
WHERE order_no = 'OP200' and pizza_id = 'p002';

select * from orders;
select * from order_list;
select * from pizza;

REM: Test DELETE
DELETE FROM order_list
WHERE order_no = 'OP200' and pizza_id = 'p005';

select * from orders;
select * from order_list;
select * from pizza;

ROLLBACK TO B;

REM: 3.To give preference to all customers in delivery of pizzas’, a threshold is set on the number of
REM: orders per day per customer. Ensure that a customer can not place more than 5 orders per day

REM: Creating Trigger

CREATE GLOBAL TEMPORARY TABLE added_rows (
    order_no ORDERS.order_no%TYPE;
) ON COMMIT PRESERVE ROWS;

CREATE OR REPLACE TRIGGER max_5_ords_per_cust_per_day
AFTER INSERT OR UPDATE OF order_date ON ORDERS
FOR EACH ROW
DECLARE
    order_count NUMBER;
BEGIN
    select COUNT(*) INTO order_count from orders
    WHERE orders.cust_id = :NEW.cust_id AND orders.order_date = :NEW.order_date;
    IF order_count >= 5 THEN
        raise_application_error(-20001, 'A customer is not allowed more than 5 orders a day!');
    END IF;
END;
/

REM: Testing Trigger
SAVEPOINT C;
select * from orders;
REM: Test insertion
insert into orders values 
(
    'OP901',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
),
(
    'OP902',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
),
(
    'OP903',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
),
(
    'OP904',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
),
(
    'OP905',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
);

REM: Only the first 4 work, the last one goes over the limit
select * from orders;

REM: Test UPDATING

UPDATE ORDERS
SET order_date = DATE '2015-06-28'
WHERE order_no = 'OP500';

select * from orders;
ROLLBACK to C;