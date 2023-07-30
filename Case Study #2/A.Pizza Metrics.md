# 🍕 Case Study #2 - Pizza Runner

## 🍝 Solution - A. Pizza Metrics

**1. How many pizzas were ordered?**

````sql
select count(pizza_id) as total_order_pizza
	from customer_orders;
````

