REM: 1. For each pizza, display the total quantity ordered by the customers.
select pizza.pizza_type as pizza_type, SUM(order_list.qty) as number_ordered from order_list
join pizza on pizza.pizza_id = order_list.pizza_id
group by pizza.pizza_id, pizza.pizza_type;

REM: 2. Find the pizza type(s) that is not delivered on the ordered day
select DISTINCT pizza.pizza_type from orders
join order_list on orders.order_no = order_list.order_no
join pizza on pizza.pizza_id = order_list.pizza_id
where orders.order_date <> orders.delv_date;

REM: 3. Display the number of order(s) placed by each customer whether or not he/she placed the order.
select customer.cust_id, customer.cust_name as cust_id, count(order_no) as num_orders from customer
left outer join orders on customer.cust_id = orders.cust_id
group by customer.cust_id, customer.cust_name;

REM: 4. Find the pairs of pizzas such that the ordered quantity of first pizza type is more than the second for the order OP100

REM: Only works in newer versions of oracle
REM: WITH order1_list as (
REM: 	select pizza_id, qty from order_list
REM:	where order_no = 'OP100'
REM:)
REM:WITH order1_list_named as (
REM:	select pizza.pizza_id as pizza_id, pizza.pizza_type as pizza_type, order1_list.qty as qty from order1_list
REM:	join pizza on order1_list.pizza_id = pizza.pizza_id
REM:)
REM:select pizza1.pizza_id, pizza1.pizza_type, pizza1.qty, pizza2.pizza_id, pizza2.pizza_type, pizza2.qty from order1_list_named pizza1
REM:join order1_list_named pizza2 on pizza1.qty > pizza2.qty;

REM: Note, for some reason, omitting 'as' in order_list as order1 , order_list as order2, makes it work.

select order1.pizza_id, order1.qty, order2.pizza_id, order2.qty from order_list order1
join order_list order2 on order1.qty > order2.qty
where order1.order_no = 'OP100' and order2.order_no = 'OP100';

REM: 5. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered
REM: quantity more than the average ordered quantity of pizzas.

select orders.order_no, pizza.pizza_type, customer.cust_name, order_list.qty from order_list
join orders on order_list.order_no = orders.order_no
join customer on orders.cust_id = customer.cust_id
join pizza on order_list.pizza_id = pizza.pizza_id
where order_list.qty > ANY (SELECT AVG(qty) from order_list);

REM: 6. Find the customer(s) who ordered for more than one pizza type in each order.

select customer.cust_id, customer.cust_name from customer
where  EXISTS (
	select * from order_list
	join orders on order_list.order_no = orders.order_no
	where orders.cust_id = customer.cust_id
) and 1 < ALL (
	select count(order_list.pizza_id) from orders
	join order_list on orders.order_no = order_list.order_no 
	where orders.cust_id = customer.cust_id
	group by orders.order_no
);

REM: 7. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered
REM: quantity more than the average ordered quantity of each pizza type

select orders.order_no, pizza.pizza_type, customer.cust_name, order_list.qty from order_list
join orders on order_list.order_no = orders.order_no
join customer on orders.cust_id = customer.cust_id
join pizza on pizza.pizza_id = order_list.pizza_id
where order_list.qty > all (
	select AVG(qty) from order_list
	group by order_list.pizza_id
);


REM: 8. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered
REM: quantity more than the average ordered quantity of its pizza type. (Use correlated)


select orders.order_no, pizza.pizza_type, customer.cust_name, order_list.qty from order_list
join orders on order_list.order_no = orders.order_no
join customer on orders.cust_id = customer.cust_id
join pizza on pizza.pizza_id = order_list.pizza_id
where order_list.qty > all (
	select AVG(qty) from order_list
	where order_list.pizza_id = pizza.pizza_id
);

REM: 9. Display the customer details who placed all pizza types in a single order
select unique c.cust_id, c.cust_name, c.address, c.phone from orders
join customer c on orders.cust_id = c.cust_id
join order_list on orders.order_no = order_list.order_no
group by orders.order_no
having count(order_list.pizza_id) = ALL(
	select count(*) from pizza
);
