# 🍕 Case Study #2 Pizza Runner

## Solution - D. Pricing and Ratings

**1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**

```sql
select
    sum(case 
				when co.pizza_id = 1 then 12 else 10 end) as pr_prices
from customer_orders  as co	
left join runner_orders as ro on co.order_id= ro.order_id
where ro.cancellation is null;
```
### 2.What if there was an additional $1 charge for any pizza extras? --Add cheese is $1 extra

```sql
with no_extras_price as

(select 
		sum
		(case 
				when co.pizza_id = 1 then 12 else 10 end) as pr_prices
from customer_orders  as co	
left join runner_orders as ro on co.order_id= ro.order_id
where ro.cancellation is null
)
, extras_price  as 

(select 
		sum(case when co.extras_id = 4 then 2 else 1 end) ext_price 
		
	from customer_orders_ as co
	join runner_orders as ro on ro.order_id = co.order_id
	where ro.cancellation is null)

	select
      concat(nep.pr_prices+ep.ext_price) as pizza_runner_revenue
from no_extras_price as nep, extras_price  as ep;
```

### 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.


```sql

create table runner_rating (
order_id int,
runner_rate int);

insert into runner_rating (order_id, runner_rate)
values
  (1,3),
  (2,5),
  (3,3),
  (4,1),
  (5,5),
  (7,3),
  (8,4),
  (10,3);
  
  select * from runner_rating;
```

### 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
	-customer_id
	-order_id
	-runner_id
	-rating
	-order_time
	-pickup_time
	-Time between order and pickup
	-Delivery duration
	-Average speed
	-Total number of pizzas

```sql

select 
	co.customer_id,
	co.order_id,
	ro.runner_id,
	rr.runner_rate,
	co.order_time,
	ro.pickup_time,
	ro.pickup_time - co.order_time as time_between_order_and_pickup,
	ro.duration as delivert_duration,
	avg(ro.distance*60/ro.duration) avg_speed,
	count(co.pizza_id) as total_number_of_number
from customer_orders as co
left join runner_orders as ro on ro.order_id = co.order_id
left join runner_rating as rr on rr.order_id = co.order_id
where ro.cancellation is null 
group by 1,2,3,4,5,6,7,8
order by 1;
```
### 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
```sql

with no_extras_price as 

(select co.order_id,
		sum
		(case 
				when co.pizza_id = 1 then 12 else 10 end) as pr_prices, 
			 sum(ro.distance) * 0.30 as runner_traveled_price
from customer_orders  as co	
left join runner_orders as ro on co.order_id= ro.order_id
where ro.cancellation is null
 group by 1
 
 )
select 
round(sum(pr_prices-runner_traveled_price),2) as diff_revenue									
from no_extras_price
		
		;
```
