SET ECHO ON

REM: Drop the Order_summary table if it already exists
DROP TABLE ORDER_SUMMARY;

REM: Drop the Complete_order table if it already exists
DROP TABLE COMPLETE_ORDER;

REM: Drop the Customer table if it already exists
DROP TABLE CUSTOMER;

REM: Drop the Employee table if it already exists
DROP TABLE EMPLOYEE;

REM: Drop the address_abs table if it already exists
DROP TABLE ADDRESS_ABS;

REM: Drop the Part_info table if it already exists
DROP TABLE PART_INFO;

REM: Drop existing tables
DROP TABLE ORDER_LIST;

REM: Drop existing tables
DROP TABLE PIZZA;

REM: Drop existing tables
DROP TABLE ORDERS;

REM: Drop existing tables
DROP TABLE CUSTOMER;

REM: Create table customer
CREATE TABLE CUSTOMER (
    CUST_ID VARCHAR(5) CONSTRAINT CUST_ID_PK PRIMARY KEY,
    CUST_NAME VARCHAR(50),
    ADDRESS VARCHAR(100),
    PHONE VARCHAR(15)
);

REM: Create table pizza
CREATE TABLE PIZZA (
    PIZZA_ID VARCHAR(5) CONSTRAINT PIZZA_ID_PK PRIMARY KEY,
    PIZZA_TYPE VARCHAR(50),
    UNIT_PRICE NUMERIC(10, 2)
);

REM: Create table orders
CREATE TABLE ORDERS (
    ORDER_NO VARCHAR(5) CONSTRAINT ORDER_NO_PK PRIMARY KEY,
    CUST_ID VARCHAR(5) CONSTRAINT FK_CUSTOMER REFERENCES CUSTOMER(CUST_ID),
    ORDER_DATE DATE,
    DELV_DATE DATE
);

REM: Create table order_list
CREATE TABLE ORDER_LIST (
    ORDER_NO VARCHAR(5) CONSTRAINT FK_ORDERS REFERENCES ORDERS(ORDER_NO),
    PIZZA_ID VARCHAR(5) CONSTRAINT FK_PIZZA REFERENCES PIZZA(PIZZA_ID),
    QTY INT CONSTRAINT QTY_NN NOT NULL,
    CONSTRAINT COMPOSITE_ORDER_DETAILS PRIMARY KEY (ORDER_NO, PIZZA_ID)
);

@'Ex3-Advanced DML/Pizza_DB.sql'
REM: 1. For each pizza, display the total quantity ordered by the customers:

SELECT
    PIZZA.PIZZA_ID,
    PIZZA.PIZZA_TYPE,
    SUM(ORDER_LIST.QTY) AS TOTAL_QUANTITY
FROM
    PIZZA
    JOIN ORDER_LIST
    ON PIZZA.PIZZA_ID = ORDER_LIST.PIZZA_ID
GROUP BY
    PIZZA.PIZZA_ID,
    PIZZA.PIZZA_TYPE;

REM: 2. Find the pizza type(s) that is not delivered on the ordered day:

SELECT
    DISTINCT PIZZA.PIZZA_TYPE
FROM
    PIZZA
    JOIN ORDER_LIST
    ON PIZZA.PIZZA_ID = ORDER_LIST.PIZZA_ID
    JOIN ORDERS
    ON ORDER_LIST.ORDER_NO = ORDERS.ORDER_NO
WHERE
    ORDERS.DELV_DATE <> ORDERS.ORDER_DATE
    OR ORDERS.DELV_DATE IS NULL;

REM: 3. Display the number of order(s) placed by each customer whether or not he/she placed the order:

SELECT
    CUSTOMER.CUST_ID,
    CUSTOMER.CUST_NAME,
    COUNT(ORDERS.ORDER_NO) AS NUM_ORDERS
FROM
    CUSTOMER
    LEFT JOIN ORDERS
    ON CUSTOMER.CUST_ID = ORDERS.CUST_ID --Use left join to display null
GROUP BY
    CUSTOMER.CUST_ID,
    CUSTOMER.CUST_NAME;

REM: 4. Find the pairs of pizzas such that the ordered quantity of the first pizza type is more than the second for the order OP100:

SELECT
    OL1.PIZZA_ID AS FIRST_PIZZA,
    OL2.PIZZA_ID AS SECOND_PIZZA
FROM
    ORDER_LIST OL1
    JOIN ORDER_LIST OL2
    ON OL1.ORDER_NO = OL2.ORDER_NO
    AND OL1.ORDER_NO = 'OP100'
WHERE
    OL1.QTY > OL2.QTY;

REM: 5. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered quantity more than the average ordered quantity of pizzas:

SELECT
    ORDER_NO,
    PIZZA_TYPE,
    CUST_NAME,
    QTY
FROM
    (
        SELECT
            O.ORDER_NO,
            P.PIZZA_TYPE,
            C.CUST_NAME,
            OL.QTY,
            AVG(OL.QTY) OVER () AS AVG_QTY
        FROM
            ORDERS     O,
            ORDER_LIST OL,
            PIZZA      P,
            CUSTOMER   C
        WHERE
            O.ORDER_NO = OL.ORDER_NO
            AND OL.PIZZA_ID = P.PIZZA_ID
            AND O.CUST_ID = C.CUST_ID
    )
WHERE
    QTY > AVG_QTY;

REM: 6. Find the customer(s) who ordered for more than one pizza type in each order:

SELECT
    C.CUST_NAME
FROM
    CUSTOMER   C,
    ORDERS     O
WHERE
    O.CUST_ID = C.CUST_ID
    AND O.ORDER_NO IN (
        SELECT
            OL.ORDER_NO
        FROM
            ORDER_LIST OL
        GROUP BY
            OL.ORDER_NO
        HAVING
            COUNT(OL.PIZZA_ID) > 1
    )
GROUP BY
    C.CUST_NAME;

REM: 7. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered quantity more than the average ordered quantity of each pizza type.

SELECT
    OL.ORDER_NO,
    PZ.PIZZA_TYPE,
    C.CUST_NAME,
    OL.QTY
FROM
    CUSTOMER   C,
    PIZZA      PZ,
    ORDERS     O,
    ORDER_LIST OL
WHERE
    C.CUST_ID = O.CUST_ID
    AND O.ORDER_NO = OL.ORDER_NO
    AND PZ.PIZZA_ID = OL.PIZZA_ID
    AND OL.QTY > ALL(
        SELECT
            AVG(OL_INNER.QTY)
        FROM
            ORDER_LIST OL_INNER
        GROUP BY
            OL_INNER.PIZZA_ID
    );

REM: 8. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered quantity more than the average ordered quantity of its pizza type. (Use correlated)

SELECT
    OL.ORDER_NO,
    PZ.PIZZA_TYPE,
    C.CUST_NAME,
    OL.QTY
FROM
    CUSTOMER   C,
    PIZZA      PZ,
    ORDERS     O,
    ORDER_LIST OL
WHERE
    C.CUST_ID = O.CUST_ID
    AND O.ORDER_NO = OL.ORDER_NO
    AND PZ.PIZZA_ID = OL.PIZZA_ID
    AND OL.QTY > (
        SELECT
            AVG(OL_INNER.QTY)
        FROM
            ORDER_LIST OL_INNER
        WHERE
            PZ.PIZZA_ID = OL_INNER.PIZZA_ID
    );

REM: 9. Display the customer details who placed all pizza types in a single order.

SELECT
    C.CUST_ID,
    C.CUST_NAME
FROM
    CUSTOMER   C,
    ORDERS     O
WHERE
    C.CUST_ID = O.CUST_ID
    AND O.ORDER_NO IN (
        SELECT
            ORDER_NO
        FROM
            ORDER_LIST
        GROUP BY
            ORDER_NO
        HAVING
            COUNT(DISTINCT PIZZA_ID) = (
                SELECT
                    COUNT(*)
                FROM
                    PIZZA
            )
    );

REM: 10. Display the order details that contain the pizza quantity more than the average quantity of any of Pan or Italian pizza type:

SELECT
    OL.ORDER_NO,
    P.PIZZA_TYPE,
    C.CUST_NAME,
    OL.QTY
FROM
    CUSTOMER   C,
    PIZZA      P,
    ORDER_LIST OL,
    ORDERS     O
WHERE
    P.PIZZA_ID = OL.PIZZA_ID
    AND C.CUST_ID = O.CUST_ID
    AND O.ORDER_NO = OL.ORDER_NO
    AND OL.QTY > (
        SELECT
            AVG(OL_INNER.QTY)
        FROM
            ORDER_LIST OL_INNER
        WHERE
            P.PIZZA_TYPE = 'pan'
    )
UNION
SELECT
    OL.ORDER_NO,
    P.PIZZA_TYPE,
    C.CUST_NAME,
    OL.QTY
FROM
    CUSTOMER   C,
    PIZZA      P,
    ORDER_LIST OL,
    ORDERS     O
WHERE
    P.PIZZA_ID = OL.PIZZA_ID
    AND O.ORDER_NO = OL.ORDER_NO
    AND C.CUST_ID = O.CUST_ID
    AND OL.QTY > (
        SELECT
            AVG(OL_INNER.QTY)
        FROM
            ORDER_LIST OL_INNER
        WHERE
            P.PIZZA_TYPE = 'italian'
    );

REM: 11. Find the order(s) that contains Pan pizza but not the Italian pizza type.

SELECT
    O.ORDER_NO,
    O.CUST_ID
FROM
    ORDERS     O,
    PIZZA      P,
    ORDER_LIST OL
WHERE
    O.ORDER_NO = OL.ORDER_NO
    AND P.PIZZA_ID = OL.PIZZA_ID
    AND P.PIZZA_TYPE = 'pan' MINUS
    SELECT
        O.ORDER_NO,
        O.CUST_ID
    FROM
        ORDERS     O,
        PIZZA      P,
        ORDER_LIST OL
    WHERE
        O.ORDER_NO = OL.ORDER_NO
        AND P.PIZZA_ID = OL.PIZZA_ID
        AND P.PIZZA_TYPE = 'italian';

REM: 12. Display the customer(s) who ordered both Italian and Grilled pizza type:

SELECT
    C.CUST_ID,
    C.CUST_NAME
FROM
    CUSTOMER   C,
    PIZZA      P,
    ORDER_LIST OL,
    ORDERS     O
WHERE
    O.ORDER_NO = OL.ORDER_NO
    AND O.CUST_ID = C.CUST_ID
    AND P.PIZZA_ID = OL.PIZZA_ID
    AND P.PIZZA_TYPE = 'italian' INTERSECT
    SELECT
        C.CUST_ID,
        C.CUST_NAME
    FROM
        CUSTOMER   C,
        PIZZA      P,
        ORDER_LIST OL,
        ORDERS     O
    WHERE
        O.ORDER_NO = OL.ORDER_NO
        AND O.CUST_ID = C.CUST_ID
        AND P.PIZZA_ID = OL.PIZZA_ID
        AND P.PIZZA_TYPE = 'grilled';