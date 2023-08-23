# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics

**1. How many pizzas were ordered?**

````sql
select count(pizza_id) as total_order_pizza
	from customer_orders;
````
| total_order_pizza |
|------------------:|
|                14 |

**2. How many unique customer orders were made?**

````sql
select count(distinct order_id) as unique_customer_order
	from customer_orders;
````
| unique_customer_order |
|----------------------:|
|                    10 |

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
| runner_id | count |
|-----------|-------|
|         1 |     4 |
|         2 |     3 |
|         3 |     1 |

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
| pizza_name   | count |
|--------------|-------|
| "Meatlovers" |     9 |
| "Vegetarian" |     3 |

**5.How many Vegetarian and Meatlovers were ordered by each customer?**

````sql
select 
	co.customer_id,
	pn.pizza_name,
	count(co.order_id) as pizza_count
from customer_orders as co 
left join pizza_names as pn on pn.pizza_id = co.pizza_id
group by 1,2
order by 1;
````
| customer_id | pizza_name   | pizza_count |
|-------------|--------------|-------------|
| 101         | "Meatlovers" |           2 |
| 101         | "Vegetarian" |           1 |
| 102         | "Meatlovers" |           2 |
| 102         | "Vegetarian" |           1 |
| 103         | "Meatlovers" |           3 |
| 103         | "Vegetarian" |           1 |
| 104         | "Meatlovers" |           3 |
| 105         | "Vegetarian" |           1 |

**6.What was the maximum number of pizzas delivered in a single order?**

````sql
select
	distinct co.order_id,
	co.customer_id,
	count(co.pizza_id) as max_pizza_count
from customer_orders as co 
left join runner_orders as ro on ro.order_id = co. order_id
where ro.cancellation is null
group by 1,2
order by max_pizza_count desc
limit 1;
````
| order_id | customer_id | max_pizza_count |
|---------:|------------:|-----------------|
|        4 |         103 |               3 |

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
select * from runner_orders

select 
 co.customer_id,
count (case 
	when co.exclusions is not null or co.extras is not null then 1  end) as pizza_change,
	count (case 
	when co.exclusions is null and co.extras is null then 1  end) as no_pizza_change
from customer_orders as co
left join runner_orders as ro on ro.order_id = co.order_id
where ro.cancellation is null
group by 1
order by 1;
````
| customer_id | pizza_change | no_pizza_change |
|------------:|-------------:|-----------------|
|         101 |            0 |              2 |
|         102 |            0 |              3 |
|         103 |            3 |              0 |
|         104 |            2 |              1 |
|         105 |            1 |              0 |

### 8. How many pizzas were delivered that had both exclusions and extras?

````sql
select 
	co.customer_id,
	co.order_id,
	count(co.pizza_id) pizza_count		
from customer_orders as co 
left join runner_orders as ro on ro.order_id = co.order_id
where ro.cancellation is null and co.exclusions is not null and co.extras is not null
group by 1,2;
````
| customer_id | order_id | pizza_count |
|------------:|---------:|------------:|
|         104 |       10 |           1 |

### 9. What was the total volume of pizzas ordered for each hour of the day?

````sql
select
	count(pizza_id),
	extract(hour from order_time) as hour_day_time
from customer_orders
	group by 2
	order by 2;
````
| count | hour_day_time |
|------:|--------------:|
|     1 |            11 |
|     3 |            13 |
|     3 |            18 |
|     1 |            19 |
|     3 |            21 |
|     3 |            23 |

### 10. What was the volume of orders for each day of the week?

````sql
select 
	to_char(order_time,'Day') as day_week,
	count(order_id) as count_order
from customer_orders
group by 1
order by 1;
````
| day_week   | count_order |
|------------|-------------|
| "Friday   " |           1 |
| "Saturday " |           5 |
| "Thursday " |           3 |
| "Wednesday" |           5 |

