REM: 1. Display the total quantity of pizza ordered by each customer. 
REM: Exclude customers with < two pizza types

select cust.cust_id, cust.cust_name, SUM(olst.qty) from customer cust
left join orders ords on cust.cust_id = ords.cust_id
left join order_list olst on ords.order_no = olst.order_no
group by cust.cust_id, cust.cust_name
having count(distinct olst.pizza_id) >= 2;

REM: 2. Display the details (order number, pizza type, customer name, qty) of the pizza with ordered quantity more than the average ordered quantity of each pizza type
REM: Convert to correlated
select olst.order_no, outer_pizza.pizza_type, cust.cust_name, olst.qty from order_list olst 
join pizza outer_pizza on olst.pizza_id = outer_pizza.pizza_id
join orders on olst.order_no = orders.order_no
join customer cust on orders.cust_id = cust.cust_id
where NOT EXISTS (
	select inner_pizza.pizza_id from pizza inner_pizza 
	join order_list inner_olst on inner_pizza.pizza_id = inner_olst.pizza_id
	group by inner_pizza.pizza_id
	having AVG(inner_olst.qty) >= olst.qty
);

REM: 3. Display the details of pizza with ordered quantity >= 6 and the pizza type should not be equal to spanish
select pizza.pizza_id, pizza.pizza_type, pizza.unit_price, SUM(order_list.qty) from pizza
join order_list on pizza.pizza_id = order_list.pizza_id
group by pizza.pizza_id, pizza.pizza_type, pizza.unit_price
having LOWER(pizza.pizza_type) <> 'spanish' AND SUM(order_list.qty) >= 6;

