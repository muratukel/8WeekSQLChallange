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
| Blue Polo Shirt - Mens        | 217683                       |
| Grey Fashion Jacket - Womens  | 209304                       |
| White Tee Shirt - Mens        | 152000                       |
## 2.What is the total quantity, revenue and discount for each segment?
````sql
select 
	pd.segment_id ,
	pd.segment_name,
	sum(s.qty) as total_quantity,
	sum(s.price*s.qty) as total_revenue_before_discount,
	sum(s.price*s.qty*(1-s.discount*0.01)) as total_revenue_with_discount,
	sum(s.price*s.qty*s.discount/100) as total_discount	
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2
````
| segment_id | segment_name         | total_quantity | total_revenue_before_discount | total_revenue_with_discount | total_discount |
|------------|----------------------|----------------|------------------------------|---------------------------|----------------|
| 4          | "Jacket"             | 11385          | 366983                       | 322705.54                 | 42451          |
| 6          | "Socks"              | 11217          | 307977                       | 270963.56                 | 35280          |
| 5          | "Shirt"              | 11265          | 406143                       | 356548.73                 | 48082          |
| 3          | "Jeans"              | 11349          | 208350                       | 183006.03                 | 23673          |
