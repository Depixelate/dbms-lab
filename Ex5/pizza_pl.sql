REM: 1.Check whether the given pizza type is available. If available, display its unit price. If not,
REM: display “The pizza is not available / Invalid pizza type”

REM: Using implicit cursor
set serveroutput on

REM: Pizza
REM:select * from pizza;

declare
p_type pizza.pizza_type%TYPE;
p_price pizza.unit_price%TYPE;
begin
	p_type:='&pizza_type';
	select unit_price into p_price from pizza
	where pizza_type = p_type;
	dbms_output.put_line(p_type || ' unit price = ' || TO_CHAR(p_price));	
	EXCEPTION
		WHEN no_data_found then
			dbms_output.put_line('The pizza is not available / Invalid pizza type');	
end;
/

REM: 2. For the given customer name and a range of order date, find whether a customer had placed any
REM: order, if so display the number of orders placed by the customer along with the order number(s).

REM: select * from customer;
REM: select * from orders;

declare 
no_records EXCEPTION;
PRAGMA exception_init(no_records, -20001 );
c_name customer.cust_name%TYPE;
range_start DATE;
range_end DATE;
num_orders NUMBER(6);
cursor c1 is
	select customer.cust_name, orders.order_no, orders.order_date from customer
	join orders on orders.cust_id = customer.cust_id;
begin
	c_name := '&customer_name';
	range_start := to_date('&range_start', 'dd/mm/yyyy');
	range_end := to_date('&range_end', 'dd/mm/yyyy');
	num_orders := 0;
	for record in c1 loop
		if record.cust_name = c_name and record.order_date >= range_start and record.order_date <= range_end then
			if num_orders = 0 then
				dbms_output.put_line('Order numbers of the orders the customer has placed: ');
			end if;
			num_orders := num_orders + 1;
			dbms_output.put_line('Order no.: ' || TO_CHAR(record.order_no));
		end if;
	end loop;
	if num_orders = 0 then
		raise no_records;
	end if;
	dbms_output.put_line('Total number of orders: ' || TO_CHAR(num_orders));
	EXCEPTION
		WHEN no_records then
			dbms_output.put_line('No orders by the given customer in the given time frame!');
end;
/

REM: 3. Display the customer name along with the details of pizza type and its quantity ordered for the
REM: given order number. Also find the total quantity ordered for the given order number as shown
REM: below:

REM: select * from orders;
REM: select * from customer;
REM: select * from order_list;

declare
no_records2 EXCEPTION;
PRAGMA exception_init(no_records2, -20002 );
oid orders.order_no%TYPE;
total_quantity order_list.qty%TYPE;
name_printed boolean;
cursor c1 is
	select orders.order_no, customer.cust_name, pizza.pizza_type, order_list.qty from orders
	join order_list on orders.order_no = order_list.order_no
	join customer on customer.cust_id = orders.cust_id
	join pizza on pizza.pizza_id = order_list.pizza_id;
begin
	total_quantity := 0;
	name_printed := false;
	oid := '&oid';
	for record in c1 loop
		if record.order_no = oid then
			if not name_printed then
				dbms_output.put_line('Customer name: ' || record.cust_name);
				name_printed := true;
			end if;
			dbms_output.put_line('Type: ' || record.pizza_type || ' Quantity: ' || record.qty);
			total_quantity := total_quantity + record.qty;
		end if;
	end loop;
	if total_quantity = 0 then
		raise no_records2;
	end if;
	dbms_output.put_line('Total Qty: ' || total_quantity);
	EXCEPTION
		WHEN no_records2 then
			dbms_output.put_line('No such order exists!');
end;
/
	
