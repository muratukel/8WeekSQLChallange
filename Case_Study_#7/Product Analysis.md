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

## 3.What is the top selling product for each segment?
````sql	
with top_selling_segment as 
(select 
	pd.segment_id,
	pd.segment_name,
	pd.product_name,
	sum(s.qty) as top_selling_product,
	rank() over (partition by segment_name order by sum(s.qty)desc) as rn
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2,3	)
select 
	segment_id,
	segment_name,
	product_name,
	top_selling_product
from top_selling_segment
	where rn=1
````
| segment_id | segment_name         | product_name                   | top_selling_product |
|------------|----------------------|--------------------------------|---------------------|
| 4          | "Jacket"             | "Grey Fashion Jacket - Womens" | 3876                |
| 3          | "Jeans"              | "Navy Oversized Jeans - Womens"| 3856                |
| 5          | "Shirt"              | "Blue Polo Shirt - Mens"       | 3819                |
| 6          | "Socks"              | "Navy Solid Socks - Mens"      | 3792                |

## 4.What is the total quantity, revenue and discount for each category?
````sql	 
select 
	pd.category_id,
	pd.category_name,
	sum(s.qty) as total_quantity,
	sum(s.price*s.qty) as total_revenue,
	sum(s.price*s.qty*(1-s.discount*0.01)) as total_revenue_with_discount,
	sum(s.price*s.qty*s.discount/100) as total_discount	
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2
````
| category_id | category_name | total_quantity | total_revenue | total_revenue_with_discount | total_discount |
|-------------|---------------|----------------|---------------|-----------------------------|----------------|
| 2           | "Mens"        | 22482          | 714120        | 627512.29                   | 83362          |
| 1           | "Womens"      | 22734          | 575333        | 505711.57                   | 66124          |

## 5.What is the top selling product for each category?
````sql	 
with top_selling_category as 
(select 
	pd.category_id,
	pd.category_name,
	pd.product_name,
	sum(s.qty) as top_selling_product,
	rank() over(partition by category_name order by sum(s.qty) desc) as rn 
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2,3)
select 
	category_id,
	category_name,
	product_name,
	top_selling_product
from top_selling_category
	where rn = 1
order by 4 desc
````
| category_id | category_name | product_name                   | top_selling_product |
|-------------|---------------|--------------------------------|---------------------|
| 1           | "Womens"      | "Grey Fashion Jacket - Womens" | 3876                |
| 2           | "Mens"        | "Blue Polo Shirt - Mens"       | 3819                |
## 6.What is the percentage split of revenue by product for each segment?
````sql
select 
	pd.segment_name,
	pd.product_name,
	sum(s.price*s.qty) as for_each_segment_product_revenue,
	(select sum(price*qty) from sales) as total_revenue,
	round((sum(s.price*s.qty)*1.0/(select sum(price*qty) from sales)*1.0)*100,2) as rate 
from product_details as pd
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2
````
| segment_name | product_name                           | for_each_segment_product_revenue | total_revenue | rate  |
|--------------|----------------------------------------|---------------------------------|---------------|-------|
| "Jacket"     | "Grey Fashion Jacket - Womens"         | 209304                          | 1289453       | 16.23 |
| "Jacket"     | "Khaki Suit Jacket - Womens"           | 86296                           | 1289453       | 6.69  |
| "Shirt"      | "Teal Button Up Shirt - Mens"          | 36460                           | 1289453       | 2.83  |
| "Socks"      | "White Striped Socks - Mens"           | 62135                           | 1289453       | 4.82  |
| "Jacket"     | "Indigo Rain Jacket - Womens"          | 71383                           | 1289453       | 5.54  |
| "Socks"      | "Pink Fluro Polkadot Socks - Mens"     | 109330                          | 1289453       | 8.48  |
| "Jeans"      | "Black Straight Jeans - Womens"        | 121152                          | 1289453       | 9.40  |
| "Shirt"      | "White Tee Shirt - Mens"               | 152000                          | 1289453       | 11.79 |
| "Shirt"      | "Blue Polo Shirt - Mens"               | 217683                          | 1289453       | 16.88 |
| "Jeans"      | "Cream Relaxed Jeans - Womens"         | 37070                           | 1289453       | 2.87  |
| "Socks"      | "Navy Solid Socks - Mens"              | 136512                          | 1289453       | 10.59 |
| "Jeans"      | "Navy Oversized Jeans - Womens"       | 50128                           | 1289453       | 3.89  |
## 7.What is the percentage split of revenue by segment for each category?
````sql	 
select 
	pd.category_name,
	pd.segment_name,
	sum(s.price*s.qty) as for_category_segment_revenue,
	(select sum(price*qty) from sales) as total_revenue,
	round((sum(s.price*s.qty)*1.0/(select sum(price*qty) from sales)*1.0)*100,5) as rate 
from product_details as pd
left join sales as s
	on s.prod_id=pd.product_id
group by 1,2
````
| category_name | segment_name | for_category_segment_revenue | total_revenue | rate      |
|---------------|--------------|-----------------------------|--------------|-----------|
| "Womens"      | "Jeans"      | 208350                      | 1289453      | 16.15801  |
| "Womens"      | "Jacket"     | 366983                      | 1289453      | 28.46036  |
| "Mens"        | "Socks"      | 307977                      | 1289453      | 23.88431  |
| "Mens"        | "Shirt"      | 406143                      | 1289453      | 31.49731  |

 

