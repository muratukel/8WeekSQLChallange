## 🖇️Case Study #7 - Balanced Tree Clothing Co.
## 📎Reporting Challenge

 Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :)
````sql
select 
	s.prod_id,
	pd.product_id,
	pd.category_name,
	pd.segment_name,
	sum(s.qty) as total_quantityi,
	sum(s.qty*s.price) as total_revenue_before_discount,
	sum(s.qty*s.price*(1-discount*0.01)) as total_revenue_with_discount,
	sum(s.qty*s.price*s.discount/100) as total_discount,
	count(distinct s.txn_id) as total_transactions,
	round(count(distinct s.txn_id)*1.0/(select count(distinct txn_id) from sales)*100,2) as penetration,
	round(sum(case 
			when s.member='t' then 1 else 0 end)*100.0/count(s.*),2) as member,
	round(sum(case 
			when s.member='f' then 1 else 0 end)*100.0/count(s.*),2) as non_member,
	round(avg(case
	   		when s.member='t' then (s.qty*s.price*(1-s.discount*0.01)) end),2)	as avg_revenue_member,	
	round(avg(case
	   		when s.member='f' then (s.qty*s.price*(1-s.discount*0.01)) end),2)	as avg_revenue_non_member
from product_details as pd
left join sales as s
	on s.prod_id=pd.product_id
where extract(month from start_txn_time) in (1,2)	
	group by 1,2,3,4
````
| prod_id   | product_id | category_name | segment_name | total_quantity | total_revenue_before_discount | total_revenue_with_discount | total_discount | total_transactions | penetration | member | non_member | avg_revenue_member | avg_revenue_non_member |
|-----------|------------|---------------|--------------|----------------|-------------------------------|-----------------------------|----------------|-------------------|-------------|--------|------------|-------------------|-----------------------|
| "2a2353"  | "2a2353"   | "Mens"        | "Shirt"      | 2495           | 142215                        | 124722.84                   | 17079          | 832               | 33.28       | 62.50  | 37.50      | 149.33            | 150.86                |
| "2feb6b"  | "2feb6b"   | "Mens"        | "Socks"      | 2403           | 69687                         | 61294.69                    | 8002           | 804               | 32.16       | 62.44  | 37.56      | 78.73             | 72.09                 |
| "5d267b"  | "5d267b"   | "Mens"        | "Shirt"      | 2454           | 98160                         | 86148.40                    | 11754          | 811               | 32.44       | 59.80  | 40.20      | 107.33            | 104.59                |
| "72f5d4"  | "72f5d4"   | "Womens"      | "Jacket"     | 2470           | 46930                         | 41147.16                    | 5365           | 822               | 32.88       | 58.39  | 41.61      | 49.11             | 51.38                 |
| "9ec847"  | "9ec847"   | "Womens"      | "Jacket"     | 2554           | 137916                        | 120820.14                   | 16705          | 834               | 33.36       | 62.71  | 37.29      | 143.57            | 147.05                |
| "b9a74d"  | "b9a74d"   | "Mens"        | "Socks"      | 2402           | 40834                         | 35956.02                    | 4517           | 817               | 32.68       | 61.44  | 38.56      | 43.93             | 44.13                 |
| "c4a632"  | "c4a632"   | "Womens"      | "Jeans"      | 2481           | 32253                         | 28300.22                    | 3562           | 824               | 32.96       | 60.92  | 39.08      | 34.80             | 33.64                 |
| "c8d436"  | "c8d436"   | "Mens"        | "Shirt"      | 2425           | 24250                         | 21250.40                    | 2682           | 832               | 33.28       | 58.89  | 41.11      | 25.55             | 25.53                 |
| "d5e9a6"  | "d5e9a6"   | "Womens"      | "Jacket"     | 2521           | 57983                         | 50989.16                    | 6598           | 844               | 33.76       | 59.72  | 40.28      | 59.62             | 61.59                 |
| "e31d39"  | "e31d39"   | "Womens"      | "Jeans"      | 2487           | 24870                         | 21819.70                    | 2730           | 824               | 32.96       | 59.59  | 40.41      | 26.21             | 26.88                 |
| "e83aa3"  | "e83aa3"   | "Womens"      | "Jeans"      | 2462           | 78784                         | 68996.48                    | 9403           | 817               | 32.68       | 60.22  | 39.78      | 83.98             | 85.16                 |
| "f084eb"  | "f084eb"   | "Mens"        | "Socks"      | 2454           | 88344                         | 77530.32                    | 10422          | 834               | 33.36       | 60.19  | 39.81      | 93.03             | 92.86                 |
