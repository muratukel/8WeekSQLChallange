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
| pizza_name   | topping_name   |
|--------------|----------------|
| "Meatlovers" | "BBQ Sauce"    |
| "Meatlovers" | "Pepperoni"    |
| "Meatlovers" | "Cheese"       |
| "Meatlovers" | "Salami"       |
| "Meatlovers" | "Chicken"      |
| "Meatlovers" | "Bacon"        |
| "Meatlovers" | "Mushrooms"    |
| "Meatlovers" | "Beef"         |
| "Vegetarian" | "Tomato Sauce" |
| "Vegetarian" | "Cheese"       |
| "Vegetarian" | "Mushrooms"    |
| "Vegetarian" | "Onions"       |
| "Vegetarian" | "Peppers"      |
| "Vegetarian" | "Tomatoes"     |

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
| topping_name | count_use_extra |
|--------------|-----------------|
| "Bacon"      |              4 |
| "Chicken"    |              1 |
| "Cheese"     |              1 |

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
| topping_name | count_exclusion |
|--------------|-----------------|
| "Cheese"     |              4 |
| "Mushrooms"  |              1 |
| "BBQ Sauce"  |              1 |

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-
### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-
### 6. For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-
### 7. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
-
