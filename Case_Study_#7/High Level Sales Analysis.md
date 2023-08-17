## 🖇️Case Study #7 - Balanced Tree Clothing Co.
## 📎High Level Sales Analysis

## 1.What was the total quantity sold for all products?
## 1. Tüm ürünler için satılan toplam miktar ne kadardı?
	 ````sql
select 	
	pd.product_name,
	sum(qty) as total_quantity
from product_details as pd 
left join sales as s 
	on s.prod_id=pd.product_id 
group by 1	
````

