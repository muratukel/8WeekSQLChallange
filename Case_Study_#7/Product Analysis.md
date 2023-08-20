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
## 8.What is the percentage split of total revenue by category?	
````sql	 
select 
	pd.category_name,
	sum(s.price*s.qty) as for_category_revenue,
	(select sum(price*qty) from sales) as total_revenue,
	round((sum(s.price*s.qty)*1.0/(select sum(price*qty) from sales)*1.0)*100,5) as rate 
from product_details as pd
left join sales as s
	on s.prod_id=pd.product_id
group by 1
 ````
| category_name | for_category_revenue | total_revenue | rate      |
|---------------|----------------------|--------------|-----------|
| "Mens"        | 714120               | 1289453      | 55.38162  |
| "Womens"      | 575333               | 1289453      | 44.61838  |
## 9.What is the total transaction “penetration” for each product? 
(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
````sql	
with transaction_penetration as 
(select 
	distinct s.txn_id,
	pd.product_name,
	sum(case when s.qty>=1 then 1 else 0 end) as penetration
from product_details as pd 
left join sales as s
	on s.prod_id=pd.product_id
	group by 1,2)
select 
	product_name,
	round((sum(penetration)*1.0/(select count(distinct txn_id) from sales)*1.0)*100,2)
from transaction_penetration
group by 1
````
| product_name                   | penetration_rate |
|--------------------------------|-----------------|
| "White Tee Shirt - Mens"       | 50.72           |
| "Navy Solid Socks - Mens"      | 51.24           |
| "Grey Fashion Jacket - Womens" | 51.00           |
| "Navy Oversized Jeans - Womens"| 50.96           |
| "Pink Fluro Polkadot Socks - Mens"| 50.32         |
| "Khaki Suit Jacket - Womens"   | 49.88           |
| "Black Straight Jeans - Womens"| 49.84           |
| "White Striped Socks - Mens"   | 49.72           |
| "Blue Polo Shirt - Mens"       | 50.72           |
| "Indigo Rain Jacket - Womens"  | 50.00           |
| "Cream Relaxed Jeans - Womens" | 49.72           |
| "Teal Button Up Shirt - Mens"  | 49.68           |
## 10.What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?	 

# ROAD 1	
````sql
WITH transaction_combination AS (
    SELECT
        s.txn_id,
        s.prod_id,
        pd.product_name
    FROM
        sales s
    JOIN
        product_details pd ON s.prod_id = pd.product_id
)
SELECT
    tc1.product_name,
    tc2.product_name,
    tc3.product_name,
    COUNT(*) AS combination_count
FROM
    transaction_combination as tc1
INNER JOIN
    transaction_combination as tc2 ON tc2.txn_id = tc1.txn_id
INNER JOIN
    transaction_combination as tc3 ON tc3.txn_id = tc2.txn_id
WHERE
    tc1.prod_id < tc2.prod_id AND tc2.prod_id < tc3.prod_id
GROUP BY
    1,2,3
ORDER BY
    combination_count DESC	
LIMIT 1;
````
| product_name                   | product_name-2                   | product_name-3               | combination_count |
|--------------------------------|----------------------------------|------------------------------|------------------|
| "White Tee Shirt - Mens"       | "Grey Fashion Jacket - Womens"   | "Teal Button Up Shirt - Mens" | 352              |

# ROAD 2
````sql
SELECT 
	S1.PROD_ID,
	S2.PROD_ID,
	S3.PROD_ID,
	COUNT(*)
FROM 
	SALES S1
JOIN 
	SALES S2 ON S1.TXN_ID = S2.TXN_ID
JOIN
	SALES S3 ON S1.TXN_ID = S3.TXN_ID AND S2.TXN_ID = S3.TXN_ID
WHERE 
	S1.PROD_ID <> S2.PROD_ID AND S2.PROD_ID <> S3.PROD_ID AND S1.PROD_ID <> S3.PROD_ID
GROUP BY 
	1,2,3
ORDER BY 
	4 DESC
LIMIT 
	6;
````
| prod_id   | prod_id-2 | prod_id-3 | count |
|-----------|-----------|-----------|-------|
| "9ec847"  | "c8d436"  | "5d267b"  | 352   |
| "5d267b"  | "c8d436"  | "9ec847"  | 352   |
| "5d267b"  | "9ec847"  | "c8d436"  | 352   |
| "9ec847"  | "5d267b"  | "c8d436"  | 352   |
| "c8d436"  | "5d267b"  | "9ec847"  | 352   |
| "c8d436"  | "9ec847"  | "5d267b"  | 352   |
