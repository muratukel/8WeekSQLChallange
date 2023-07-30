# 🍕 Case Study #2 Pizza Runner

## Solution - C. Ingredient Optimisation

### 1. What are the standard ingredients for each pizza?

```sql
with table1 as 
(
select 
    	unnest(string_to_array(toppings,','))::numeric as recipes_id,
    	pr.pizza_id,
    	pizza_name
from pizza_recipes as pr
left join pizza_names as pn ON pn.pizza_id = pr.pizza_id
)
select 	
		pizza_name,
        pt.topping_name
from table1 as t1
left join pizza_toppings as pt ON t1.recipes_id = pt.topping_id
order by pizza_id;
```

### 2. What was the most commonly added extra?

```sql
with extra as 
(
	select 
 		order_id,
		unnest(string_to_array(extras,','))::numeric as extra
from customer_orders 
where extras is not null
order by extra desc
	)

select 	
		pt.topping_name,
		count(extra) as count_use_extra 
from extra as e 
left join pizza_toppings as pt on pt.topping_id = e.extra 
group by 1
order by count_use_extra desc;
```

### 3. What was the most common exclusion?
```sql

with exclusion as 
(select 
 		order_id,
		unnest(string_to_array(exclusions,','))::numeric as exclusions
from customer_orders 
where exclusions is not null
)

select 
		pt.topping_name,
		count(exclusions) as count_exclusion
from exclusion as e 
left join pizza_toppings as pt on pt.topping_id = e.exclusions
group by 1
order by count_exclusion desc;
```

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
```sql

select  
		co.order_id,
	co.customer_id,
	co.pizza_id,
	pn.pizza_name,
	 
	case 
		when pt.topping_id in (select unnest(string_to_array(extras, ','))::numeric from customer_orders) then 
				concat('2x', pt.topping_name) else pt.topping_name end as ext_topping,
	case 	
		when pt_topping_id in (select unnest(string_to_array(exclusions, ','))::numeric from customer_orders ) then 
			replace(pt.topping_name, pt.topping_name, '') else topping_name end as exc_topping
	
	from customer_orders as co
	left join pizza_names as pn on pn.pizza_id = co.pizza_id
	left join pizza_recipes as pr on pr.pizza_id=co.pizza_id
	left join pizza_toppings as pt on pt.topping_id=pr.toppings;
```

### 6. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-
### 7. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-
