# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics

**1. How many pizzas were ordered?**

````sql
select count(pizza_id) as total_order_pizza
	from customer_orders;
````

**2. How many unique customer orders were made?**

````sql
select count(distinct order_id) as unique_customer_order
	from customer_orders;
````

**3. How many successful orders were delivered by each runner?**

````sql
select 
	runner_id , 
	count(order_id)
from runner_orders
where pickup_time is not null 
group by 1
order by 1;
````

**4. How many of each type of pizza was delivered?**

````sql
select 
	pn.pizza_name,
	count(co.order_id)
from pizza_names as pn
left join customer_orders as co on co.pizza_id = pn.pizza_id
left join runner_orders as ro on ro.order_id = co.order_id
where ro.cancellation is null
group by 1;
````

**5.How many Vegetarian and Meatlovers were ordered by each customer?**

````sql
elect 
	co.customer_id,
	pn.pizza_name,
	count(co.order_id) as pizza_count
from customer_orders as co 
left join pizza_names as pn on pn.pizza_id = co.pizza_id
group by 1,2
order by 1;
````
