## 🖇️Case Study #7 - Balanced Tree Clothing Co.
## 📎High Level Sales Analysis

## 1.What was the total quantity sold for all products?

````sql
select 	
	pd.product_name,
	sum(qty) as total_quantity
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id 
group by 1	
````

## 2.What is the total generated revenue for all products before discounts?	

````sql	 
select 
	pd.product_name,
	sum(s.price) * sum(s.qty) as total_revenue 
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id
group by 1
````
## 3.What was the total discount amount for all products?

````sql 
select 
	pd.product_name,
	sum(s.price * s.qty * s.discount/100) as total_discount
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id
group by 1	
````
