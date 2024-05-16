SET SERVEROUTPUT ON;

SET ECHO ON;

REM: 1. Ensure that the pizza can be delivered on same day or on the next day only.
REM: Creating trigger
CREATE OR REPLACE TRIGGER SAME_OR_NEXT_DELV_DATE BEFORE
    INSERT OR UPDATE OF ORDER_DATE, DELV_DATE ON ORDERS FOR EACH ROW WHEN (NEW.DELV_DATE - NEW.ORDER_DATE >=2
    OR NEW.DELV_DATE - NEW.ORDER_DATE < 0)
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Delivery Date is either before or more than 1 day after the order date');
END;
/

REM: Testing trigger
REM: valid insert
SAVEPOINT A;

SELECT
    *
FROM
    ORDERS;

INSERT INTO ORDERS VALUES (
    'OP950',
    'c001',
    DATE '2024-09-05',
    DATE '2024-09-05'
);

SELECT
    *
FROM
    ORDERS;

REM: invalid insert

INSERT INTO ORDERS VALUES (
    'OP960',
    'c001',
    DATE '2024-09-05',
    DATE '2024-09-07'
);

SELECT
    *
FROM
    ORDERS;

REM: valid UPDATE

UPDATE ORDERS
SET
    DELV_DATE = ORDER_DATE
WHERE
    DELV_DATE > ORDER_DATE;

SELECT
    *
FROM
    ORDERS;

REM: invalid UPDATE

UPDATE ORDERS
SET
    DELV_DATE = ORDER_DATE - 1;

SELECT
    *
FROM
    ORDERS;

ROLLBACK TO A;

REM: 2. Update the total_amt in ORDERS while entering an order in ORDER_LIST

REM: Adding total_amt to orders

ALTER TABLE ORDERS ADD TOTAL_AMT NUMBER;

UPDATE ORDERS OUTER_ORD
SET
    TOTAL_AMT = (
        SELECT
            SUM(P.UNIT_PRICE * OL.QTY)
        FROM
            ORDERS     O
            JOIN ORDER_LIST OL
            ON O.ORDER_NO = OL.ORDER_NO
            JOIN PIZZA P
            ON OL.PIZZA_ID = P.PIZZA_ID
        WHERE
            O.ORDER_NO = OUTER_ORD.ORDER_NO
    );

REM: Declaring TRIGGER
CREATE OR REPLACE TRIGGER UPDATE_TOTAL_AMT AFTER
    INSERT OR DELETE OR UPDATE OF PIZZA_ID, QTY ON ORDER_LIST
DECLARE
    DISC_AMT NUMBER;
    CURSOR c1 IS
        SELECT
            SUM(P.UNIT_PRICE * OL.QTY) total_amt, o.order_no ono
        FROM
            ORDERS     O
            JOIN ORDER_LIST OL
            ON O.ORDER_NO = OL.ORDER_NO
            JOIN PIZZA P
            ON OL.PIZZA_ID = P.PIZZA_ID;
BEGIN
    FOR record in c1 LOOP
        DISC_AMT := 0;
        IF record.total_amt >= 3000 THEN
            DISC_AMT := 0.20 * record.total_amt;
            dbms_output.put_line('Total Amount for Order ' || record.ono || ' is >= Rs.3000, so applying a discount of 20%, for a total discount amount of Rs.' || DISC_AMT);
        END IF;
        UPDATE ORDERS
        SET TOTAL_AMT = record.total_amt - disc_amt
        WHERE order_no = record.ono;
    END LOOP;

    -- UPDATE ORDERS OUTER_ORD
    -- SET
    --     TOTAL_AMT = (
    --         SELECT
    --             SUM(P.UNIT_PRICE * OL.QTY)
    --         FROM
    --             ORDERS     O
    --             JOIN ORDER_LIST OL
    --             ON O.ORDER_NO = OL.ORDER_NO
    --             JOIN PIZZA P
    --             ON OL.PIZZA_ID = P.PIZZA_ID
    --         WHERE
    --             O.ORDER_NO = OUTER_ORD.ORDER_NO
    --     );
END;
/

REM: testing trigger

SAVEPOINT B;

SELECT
    *
FROM
    ORDERS;

SELECT
    *
FROM
    ORDER_LIST;

SELECT
    *
FROM
    PIZZA;

REM: Test insert

INSERT INTO ORDER_LIST VALUES (
    'OP200',
    'p002',
    3
);

SELECT
    *
FROM
    ORDERS;

SELECT
    *
FROM
    ORDER_LIST;

SELECT
    *
FROM
    PIZZA;

REM: Test update

UPDATE ORDER_LIST
SET
    PIZZA_ID = 'p005',
    QTY = 4
WHERE
    ORDER_NO = 'OP200'
    AND PIZZA_ID = 'p002';

SELECT
    *
FROM
    ORDERS;

SELECT
    *
FROM
    ORDER_LIST;

SELECT
    *
FROM
    PIZZA;

REM: Test DELETE
DELETE FROM ORDER_LIST
WHERE
    ORDER_NO = 'OP200'
    AND PIZZA_ID = 'p005';

SELECT
    *
FROM
    ORDERS;

SELECT
    *
FROM
    ORDER_LIST;

SELECT
    *
FROM
    PIZZA;

ROLLBACK TO B;

ALTER TABLE ORDERS DROP COLUMN DISCOUNT_TOTAL;

REM: 3.To give preference to all customers in delivery of pizzas’, a threshold is set on the number of
REM: orders per day per customer. Ensure that a customer can not place more than 5 orders per day

REM: Creating Trigger

CREATE GLOBAL TEMPORARY TABLE ADDED_ROWS (
    ORDER_NO CHAR(5)
) ON COMMIT DELETE ROWS;

CREATE OR REPLACE TRIGGER MAX_5_ORDS_PER_CUST_PER_DAY_ROW AFTER
    INSERT ON ORDERS FOR EACH ROW
DECLARE
BEGIN
    INSERT INTO ADDED_ROWS VALUES(
        :NEW.ORDER_NO
    );
END;
/

CREATE OR REPLACE TRIGGER MAX_5_ORDS_PER_CUST_PER_DAY_STATEMENT AFTER
    INSERT ON ORDERS
DECLARE
    CURSOR C1 IS
    SELECT
        *
    FROM
        ADDED_ROWS;
    ORDER_COUNT NUMBER;
    CID         ORDERS.CUST_ID%TYPE;
    ODATE       DATE;
BEGIN
    FOR ONO IN C1 LOOP
        SELECT
            O.CUST_ID,
            O.ORDER_DATE INTO CID,
            ODATE
        FROM
            ORDERS O
        WHERE
            O.ORDER_NO = ONO.ORDER_NO;
        SELECT
            COUNT(*) INTO ORDER_COUNT
        FROM
            ORDERS
        WHERE
            ORDERS.CUST_ID = CID
            AND ORDERS.ORDER_DATE = ODATE;
        IF ORDER_COUNT > 5 THEN
            DBMS_OUTPUT.PUT_LINE('Error! '
                                 || CID
                                 || ' has placed too many orders today! Deleting order...');
            DELETE FROM ORDERS O
            WHERE
                O.ORDER_NO = ONO.ORDER_NO;
        END IF;
    END LOOP;
    DELETE FROM ADDED_ROWS;
END;
/

REM: Testing Trigger
SAVEPOINT C;

SELECT
    *
FROM
    ORDERS;

REM: Test insertion
INSERT INTO ORDERS VALUES (
    'OP901',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
);

INSERT INTO ORDERS VALUES (
    'OP902',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
);

INSERT INTO ORDERS VALUES (
    'OP903',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
);

INSERT INTO ORDERS VALUES (
    'OP904',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
);

INSERT INTO ORDERS VALUES (
    'OP905',
    'c001',
    DATE '2015-06-28',
    DATE '2015-06-28',
    0
);

REM: Only the first 4 work, the last one goes over the limit
SELECT
    *
FROM
    ORDERS;

REM: Test UPDATING

ROLLBACK TO C;

REM: 4. Create a DDL TRIGGER
REM: Here I am going to create a CREATE TABLE trigger on the database, which occurs before the triggering statement, and prevents any modification to the database.
CREATE OR REPLACE TRIGGER NO_MODIFY BEFORE DDL ON DATABASE
DECLARE
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'No modification to the database allowed!');
END;
/

REM: TEst TRIGGER
CREATE TABLE TEST_TABLE (
    TEST_ATTR NUMBER,
    OTHER_TEST_ATTR VARCHAR2(255)
);

SELECT
    *
FROM
    TEST_TABLE;

ALTER TABLE ORDERS ADD TEST_ATTR DATE;

SELECT
    *
FROM
    ORDERS;

DROP TABLE PIZZA;

SELECT
    *
FROM
    PIZZA;

DROP TRIGGER NO_MODIFY;
