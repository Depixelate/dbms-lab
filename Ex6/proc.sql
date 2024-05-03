REM: 1.Write a stored procedure to display the total number of pizzas ordered by
REM: the given order number. (Use IN, OUT)


SET SERVEROUTPUT ON
SET ECHO ON


CREATE OR REPLACE PROCEDURE total_pizzas (ono IN ORDERS.order_no%TYPE, num_orders OUT NUMBER) IS
BEGIN
    select count(*) INTO num_orders from ORDERS ord
    JOIN ORDER_LIST olst on ord.order_no = olst.order_no
    WHERE ord.order_no = ono;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('ERROR! No such order number exists!');
END;
/




DECLARE
    order_no ORDERS.order_no%TYPE;
    num_pizzas NUMBER;
BEGIN
    order_no := '&order_no';
    total_pizzas(order_no, num_pizzas);
    IF num_pizzas = 0 THEN
        RAISE no_data_found;
    END IF;
    dbms_output.put_line('Number of pizzas corresponding to ' || TO_CHAR(order_no) || ' is ' || TO_CHAR(num_pizzas));
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('ERROR! No such order number exists!');
END;
/

REM: 2. For the given order number, calculate the Discount as follows:
REM: For total amount > 2000 and total amount < 5000: Discount=5%
REM: For total amount > 5000 and total amount < 10000: Discount=10%
REM: For total amount > 10000: Discount=20%
REM: Calculate the total amount (after the discount) and update the same in
REM: orders table. Print the order as shown below:
REM: ************************************************************
REM: Order Number:OP104 Customer Name: Hari
REM: Order Date :29-Jun-2015 Phone: 9001200031
REM: ************************************************************
REM: SNo Pizza Type Qty Price Amount
REM: 1. Italian 6 200 1200
REM: 2. Spanish 5 260 1300
REM: ------------------------------------------------------
REM: Total = 11 2500
REM: ------------------------------------------------------
REM: Total Amount :Rs.2500
REM: Discount (5%) :Rs. 125
REM: -------------------------- ----
REM: Amount to be paid :Rs.2375
REM: -------------------------- ----
REM: Great Offers! Discount up to 25% on DIWALI Festival Day...
REM: *************************************************************
ALTER TABLE ORDERS
ADD discount_total NUMBER;

DECLARE
    ono ORDERS.order_no%TYPE;
    order_info ORDERS%ROWTYPE;
    customer_name CUSTOMER.cust_name%TYPE;
    customer_phone CUSTOMER.phone%TYPE;
    discount_pct NUMBER;
    total_amount NUMBER;
    total_qty NUMBER;
    discount_amt NUMBER;
    net_amt NUMBER;
    CURSOR c1 (ordno ORDERS.order_no%TYPE) is
        select
        ROWNUM as sno, 
        p.pizza_type as p_type,
        olst.qty as quantity,
        p.unit_price as price,
        olst.qty * p.unit_price as amount
        FROM ORDERS ord
        join ORDER_LIST olst on ord.order_no = olst.order_no
        join PIZZA p on olst.pizza_id = p.pizza_id
        where ord.order_no = ordno;
BEGIN
    ono := '&order_no';
    total_amount := 0;
    total_qty := 0;


    select * into order_info from orders
    where orders.order_no = ono;


    select cust_name, phone into customer_name, customer_phone from customer
    where customer.cust_id = order_info.cust_id;

    dbms_output.put_line('************************************************************
');
    dbms_output.put_line('Order Number: ' || ono || ' Customer Name: ' || customer_name);
    dbms_output.put_line('Order Date: ' || TO_CHAR(order_info.order_date) || ' Phone: ' || customer_phone);
    dbms_output.put_line('************************************************************');

    dbms_output.put_line('SNo Pizza Type Qty Price Amount');

    for rec in c1(ono) loop
        dbms_output.put_line(rec.sno || '.   ' || rec.p_type || '   ' || TO_CHAR(rec.quantity) || '   ' || TO_CHAR(rec.price) || '   ' || TO_CHAR(rec.amount));
        total_amount := total_amount + rec.amount;
        total_qty := total_qty + rec.quantity;
    end loop;

    IF total_qty = 0 THEN
        raise no_data_found;
    END IF;

    IF total_amount >= 10000 THEN
        discount_pct := 20;
    ELSIF total_amount >= 5000 THEN
        discount_pct := 10;
    ELSIF total_amount >= 2000 THEN
        discount_pct := 5;
    ELSE
        discount_pct := 0;
    END IF;

    discount_amt := total_amount * discount_pct / 100;
    net_amt := total_amount - discount_amt;

    UPDATE orders
    set discount_total = net_amt
    where orders.order_no = ono;

    dbms_output.put_line('------------------------------------------------------');
    dbms_output.put_line('Total = ' || TO_CHAR(total_qty) || '  ' || TO_CHAR(total_amount));
    dbms_output.put_line('------------------------------------------------------');
    dbms_output.put_line('Total Amount: Rs.' || TO_CHAR(total_amount));
    dbms_output.put_line('Discount (' || TO_CHAR(discount_pct) || '%): Rs.' || TO_CHAR(discount_amt));
    dbms_output.put_line('------------------------------------------------------');
    dbms_output.put_line('Amount to be paid: Rs. ' || TO_CHAR(net_amt));
    dbms_output.put_line('-------------------------- ----');
    dbms_output.put_line('Great Offers! Discount up to 25% on DIWALI Festival Day...');
    dbms_output.put_line('*************************************************************');


EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Error! There is no order with the given order number!');
END;
/



REM: 3. Write a stored function to display the customer name who ordered highest among the total
REM: number of pizzas for a given pizza type.
CREATE OR REPLACE PROCEDURE most_pizza_cust(
    p_type IN PIZZA.PIZZA_TYPE%TYPE,
    c_name out CUSTOMER.cust_name%TYPE
) IS
BEGIN
    select a.cust_name into c_name from (
        select c.cust_name cust_name from PIZZA p
        join ORDER_LIST ol on ol.PIZZA_ID = p.PIZZA_ID
        join ORDERS o on o.ORDER_NO = ol.ORDER_NO
        join CUSTOMER c on c.CUST_ID = o.CUST_ID
        where LOWER(p.PIZZA_TYPE) = LOWER(p_type)
        group by c.CUST_ID, c.cust_name
        order by SUM(ol.QTY) DESC
    ) a WHERE ROWNUM = 1;
END;
/

DECLARE
    p_type PIZZA.PIZZA_TYPE%TYPE;
    c_name CUSTOMER.CUST_NAME%TYPE;
BEGIN
    p_type := '&pizza_type';
    most_pizza_cust(p_type, c_name);
    dbms_output.put_line('Name of the customer who has ordered the most ' || p_type || ' is ' || c_name);
EXCEPTION
    when no_data_found THEN
        dbms_output.put_line('Either the pizza type does not exist, or no customer has ever ordered this pizza type!');
END;
/

REM: 4. Implement Question (2) using a stored function to return the amount to be paid and update the
REM: same, for the given order number
ALTER TABLE ORDERS
ADD discount_total NUMBER;

DROP TYPE table_type;
DROP TYPE rec_type;

CREATE OR REPLACE TYPE rec_type AS OBJECT (
  sno           NUMBER,
  p_type VARCHAR2(100),
  qty NUMBER,
  price NUMBER,
  amount NUMBER
);
/

CREATE OR REPLACE TYPE table_type AS TABLE OF rec_type;
/

CREATE OR REPLACE PROCEDURE calc_discount(
    ono IN ORDERS.order_no%TYPE,
    order_info out ORDERS%ROWTYPE,
    ret out table_type,
    customer_name out CUSTOMER.cust_name%TYPE,
    customer_phone out CUSTOMER.phone%TYPE,
    discount_pct out NUMBER,
    total_amount out NUMBER,
    total_qty out NUMBER,
    discount_amt out NUMBER,
    net_amt out NUMBER
    ) IS
    CURSOR c1 (ordno ORDERS.order_no%TYPE) is
        select
        p.pizza_type as p_type,
        olst.qty as quantity,
        p.unit_price as price,
        olst.qty * p.unit_price as amount
        FROM ORDERS ord
        join ORDER_LIST olst on ord.order_no = olst.order_no
        join PIZZA p on olst.pizza_id = p.pizza_id
        where ord.order_no = ordno;
    sno NUMBER;
BEGIN
    sno := 1;
    ret := table_type();
    total_amount := 0;
    total_qty := 0;


    select * into order_info from orders
    where orders.order_no = ono;


    select cust_name, phone into customer_name, customer_phone from customer
    where customer.cust_id = order_info.cust_id;


    for rec in c1(ono) loop
        ret.extend;
        ret(ret.count) := rec_type(sno, rec.p_type, rec.quantity, rec.price, rec.amount);
        total_amount := total_amount + rec.amount;
        total_qty := total_qty + rec.quantity;
        sno := sno + 1;
    end loop;


    IF total_amount >= 10000 THEN
        discount_pct := 20;
    ELSIF total_amount >= 5000 THEN
        discount_pct := 10;
    ELSIF total_amount >= 2000 THEN
        discount_pct := 5;
    ELSE
        discount_pct := 0;
    END IF;


    discount_amt := total_amount * discount_pct / 100;
    net_amt := total_amount - discount_amt;


    UPDATE orders
    set discount_total = net_amt
    where orders.order_no = ono;
END;
/


DECLARE
    ono ORDERS.order_no%TYPE;
    order_info ORDERS%ROWTYPE;
    ret table_type;
    customer_name CUSTOMER.cust_name%TYPE;
    customer_phone CUSTOMER.phone%TYPE;
    discount_pct NUMBER;
    total_amount NUMBER;
    total_qty NUMBER;
    discount_amt NUMBER;
    net_amt NUMBER;
BEGIN
    ono := '&order_no';
    calc_discount(ono, order_info, ret, customer_name, customer_phone, discount_pct, total_amount, total_qty, discount_amt, net_amt);
    IF total_qty = 0 THEN
        raise no_data_found;
    END IF;
    dbms_output.put_line('************************************************************
');
    dbms_output.put_line('Order Number: ' || ono || ' Customer Name: ' || customer_name);
    dbms_output.put_line('Order Date: ' || TO_CHAR(order_info.order_date) || ' Phone: ' || customer_phone);
    dbms_output.put_line('************************************************************');


    dbms_output.put_line('SNo Pizza Type Qty Price Amount');
    for i in 1..ret.count loop
        dbms_output.put_line(ret(i).sno || '.   ' || ret(i).p_type || '   ' || TO_CHAR(ret(i).qty) || '   ' || TO_CHAR(ret(i).price) || '   ' || TO_CHAR(ret(i).amount));
    end loop;
    dbms_output.put_line('------------------------------------------------------');
    dbms_output.put_line('Total = ' || TO_CHAR(total_qty) || '  ' || TO_CHAR(total_amount));
    dbms_output.put_line('------------------------------------------------------');
    dbms_output.put_line('Total Amount: Rs.' || TO_CHAR(total_amount));
    dbms_output.put_line('Discount (' || TO_CHAR(discount_pct) || '%): Rs.' || TO_CHAR(discount_amt));
    dbms_output.put_line('------------------------------------------------------');
    dbms_output.put_line('Amount to be paid: Rs. ' || TO_CHAR(net_amt));
    dbms_output.put_line('-------------------------- ----');
    dbms_output.put_line('Great Offers! Discount up to 25% on DIWALI Festival Day...');
dbms_output.put_line('*************************************************************');
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Error! There is no order with the given order number!');
END;
/

