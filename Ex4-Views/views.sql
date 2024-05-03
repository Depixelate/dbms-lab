REM: 1. An user is interested to have list of pizza’s in the range of Rs.200-250. Create a view  Pizza_200_250 which keeps the pizza details that has the price in the range of 200 to 250.

DROP VIEW PIZZA_200_250;
DROP VIEW PIZZA_TYPE_ORDER;
DROP VIEW SPANISH_CUSTOMERS;

SET AUTOCOMMIT OFF;

CREATE OR REPLACE VIEW PIZZA_200_250 AS (
	SELECT
		*
	FROM
		PIZZA
	WHERE
		UNIT_PRICE BETWEEN 200 AND 250
);

SELECT
	*
FROM
	PIZZA_200_250;

SAVEPOINT Q1;

ROLLBACK TO Q1;

Rem: Update View
UPDATE PIZZA_200_250
SET
	UNIT_PRICE = UNIT_PRICE * 1.02;

SELECT
	*
FROM
	PIZZA_200_250;

ROLLBACK TO Q1;

REM: Insert into view
INSERT INTO PIZZA_200_250 VALUES (
	'p010',
	'Hawaian',
	225
);

ROLLBACK TO Q1;

SELECT
	*
FROM
	PIZZA_200_250;

SELECT
	*
FROM
	PIZZA;

ROLLBACK TO Q1;

ROLLBACK TO Q1;

Rem: Delete from view
DELETE FROM PIZZA_200_250
WHERE
	UNIT_PRICE >= 230;

SELECT
	*
FROM
	PIZZA_200_250;

ROLLBACK TO Q1;

SELECT
	*
FROM
	PIZZA_200_250;

REM: 2.  Pizza company owner is interested to know the number of pizza types ordered in each order.
REM: Create a view Pizza_Type_Order that lists the number of pizza types ordered in each order.

CREATE OR REPLACE VIEW PIZZA_TYPE_ORDER(
	ORDER_NO,
	NUM_PIZZA_TYPES
) AS (
	SELECT
		ORDERS.ORDER_NO,
		COUNT(ORDER_LIST.PIZZA_ID)
	FROM
		ORDERS
		LEFT JOIN ORDER_LIST
		ON ORDERS.ORDER_NO = ORDER_LIST.ORDER_NO
	GROUP BY
		ORDERS.ORDER_NO
);

SELECT
	*
FROM
	PIZZA_TYPE_ORDER;

SAVEPOINT Q2;

REM: Insert into view
INSERT INTO PIZZA_TYPE_ORDER VALUES (
	'OP900',
	12
);

SELECT
	*
FROM
	PIZZA_TYPE_ORDER;

REM: Update view

UPDATE PIZZA_TYPE_ORDER
SET
	NUM_PIZZA_TYPES = NUM_PIZZA_TYPES + 1;

SELECT
	*
FROM
	PIZZA_TYPE_ORDER;

REM: Delete from view
DELETE FROM PIZZA_TYPE_ORDER
WHERE
	NUM_PIZZA_TYPES < 2;

SELECT
	*
FROM
	PIZZA_TYPE_ORDER;

ROLLBACK TO Q2;

SELECT
	*
FROM
	PIZZA_TYPE_ORDER;

REM: 3. To know about the customers of Spanish pizza, create a view Spanish_Customers that list out
REM: the customer id, name, order_no of customers who ordered Spanish type

CREATE OR REPLACE VIEW SPANISH_CUSTOMERS AS (
	SELECT CUST.CUST_ID, CUST.CUST_NAME, ORDER_LIST.ORDER_NO FROM CUSTOMER CUST
		JOIN ORDERS
		ON CUST.CUST_ID = ORDERS.CUST_ID
		JOIN ORDER_LIST
		ON ORDERS.ORDER_NO = ORDER_LIST.ORDER_NO
	WHERE
		ORDER_LIST.PIZZA_ID = (
			SELECT
				PIZZA_ID
			FROM
				PIZZA
			WHERE
				LOWER(PIZZA_TYPE) = 'spanish'
		)
);

SELECT
	*
FROM
	SPANISH_CUSTOMERS;

SELECT
	COLUMN_NAME,
	UPDATABLE
FROM
	USER_UPDATABLE_COLUMNS
WHERE
	TABLE_NAME = 'SPANISH_CUSTOMERS';

SAVEPOINT Q3;

REM: Insert into view: (non-primary key preserved table included)
INSERT INTO SPANISH_CUSTOMERS VALUES (
	'c011',
	'Ajay',
	'OP011'
);

SELECT
	*
FROM
	SPANISH_CUSTOMERS;

REM: Insert into view: (only primary key preserved table)
INSERT INTO SPANISH_CUSTOMERS(
	ORDER_NO
) VALUES (
	'OP900'
);

SELECT
	*
FROM
	SPANISH_CUSTOMERS;

SELECT
	*
FROM
	CUSTOMER;

SELECT
	*
FROM
	ORDERS;

REM: Update View(Non-key-preserved)
UPDATE SPANISH_CUSTOMERS
SET
	CUST_NAME = 'Ram'
WHERE
	CUST_ID = 'c001';

SELECT
	*
FROM
	SPANISH_CUSTOMERS;

REM: Update View(Key-preserved)
UPDATE SPANISH_CUSTOMERS
SET
	ORDER_NO = 'OP801'
WHERE
	ORDER_NO = 'OP100';

SELECT
	*
FROM
	SPANISH_CUSTOMERS;

SELECT
	*
FROM
	ORDERS;

SELECT
	*
FROM
	CUSTOMER;

REM: Delete from View
DELETE FROM SPANISH_CUSTOMERS
WHERE
	CUST_ID = 'c001';

SELECT
	*
FROM
	SPANISH_CUSTOMERS;

SELECT
	*
FROM
	ORDERS;

SELECT
	*
FROM
	CUSTOMER;

ROLLBACK TO Q3;

SELECT
	*
FROM
	SPANISH_CUSTOMERS;

SELECT
	*
FROM
	ORDERS;

SELECT
	*
FROM
	CUSTOMER;