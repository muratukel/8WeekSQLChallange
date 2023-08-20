## 🖇️Case Study #7 - Balanced Tree Clothing Co.
## 📎Product Analysis
## 1.What are the top 3 products by total revenue before discount?
````sql
select 
	pd.product_name,
	sum(s.price*s.qty) as total_revenue_before_discount
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1
order by 2 desc 
limit 3
````
| Product Name                   | Total Revenue Before Discount |
|-------------------------------|------------------------------|
| Blue Polo Shirt - Mens        | 217,683                      |
| Grey Fashion Jacket - Womens  | 209,304                      |
| White Tee Shirt - Mens        | 152,000                      |
