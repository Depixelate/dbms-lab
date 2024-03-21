REM: 1. For each pizza, display the total quantity ordered by the customers.
select pizza_id, SUM(qty) as num_pizzas from PIZZA
group by pizza_id;

REM: 2. Find the pizza type(s) that is not delivered on the ordered day
select order.order_date as order_date, pizza.pizza_type as pizza_type from order_list
join order_list on order.order_no = order_list.order_no
right join pizza on pizza.pizza_id = order_list.pizza_id
group by order.order_date, pizza.pizza_type
having count(*) > 0
