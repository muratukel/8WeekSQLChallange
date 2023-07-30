# 🍕 Case Study #2 Pizza Runner

## Solution - B. Runner and Customer Experience

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
select 
		count(runner_id) as runners_count,
		to_char(registration_date,'w') as week_period		
from runners  
group by 2
order by 2;
````

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
with diff_order_pick as 
(select 

	distinct runner_id,
	avg(age(ro.pickup_time::timestamp,co.order_time::timestamp) ) as avg_diff_order_pick
	from runner_orders as ro
left join customer_orders as co on co.order_id = roage(ro.pickup_time::timestamp,co.order_time::timestamp).order_id
group by 1 
order by 1)

select 	
		distinct runner_id,
		extract(minute from avg_diff_order_pick)
		
	from diff_order_pick
		order by 1;
````
### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
 with orders as 
  
  (
	  select 
  			count(co.pizza_id) as pizza_count,
			age(ro.pickup_time::timestamp,co.order_time::timestamp) as ready_time
  from customer_orders as co 
  left join runner_orders as ro on ro.order_id = co.order_id
  where ro.cancellation is null
  group by 2
  
  )
   
  select 
  		pizza_count,
		avg(ready_time) as avg_ready_time
from orders 
	group by 1
	order by 1;
````

### 4. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
select 
		co.customer_id,
		round(avg(ro.distance::numeric),2) as avg_travel_distance 
from customer_orders as co 
left join runner_orders as ro on ro.order_id = co.order_id 
group by 1
order by 1;
````

### 5. What was the difference between the longest and shortest delivery times for all orders?

````sql
select 
		count(co.order_id) as total_orders,
		(max(ro.duration::numeric) - min(ro.duration::numeric ) )as longest_shortest_delivered		
from customer_orders as co
left join runner_orders as ro on ro.order_id = co.order_id 
where ro.cancellation is null;
````

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql 
select			
		   distinct runner_id,order_id,
		   round(avg(distance::numeric / (duration::numeric/60)),2) as avg_speed		
from runner_orders 
		where cancellation is null	
group by 1,2			
order by 2;
````
### 7. What is the successful delivery percentage for each runner?

````sql 
with suc_delivered as 
(
	select 
		runner_id,
		count(order_id)::numeric as succes_order			 
  from runner_orders 
  where cancellation is null 
group by 1
 order by 1
) 
  , total_delivered as 
  
 (
	 select runner_id,
  count(order_id)::numeric as total_order
	 from runner_orders
	 group by 1
	 order by 1
 ) 
  select 
  		sd.runner_id,
		round((sd.succes_order / td.total_order)*100,2) as succes_ratio 
		
	from suc_delivered as sd 
	left join total_delivered as td on td.runner_id = sd.runner_id 
	order by 1
;
````
