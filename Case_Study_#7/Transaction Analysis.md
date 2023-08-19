## 🖇️Case Study #7 - Balanced Tree Clothing Co.
## 📎Transaction Analysis

## 1.How many unique transactions were there? 
```sql	 
select 
	count(distinct txn_id) as total_transactions 
from sales	
```
| Total Transactions |
|---------------------|
|        2500         |

## 2.What is the average unique products purchased in each transaction
# According to the number of quantities
````sql
with in_each_transaction as 
(
	select 
	txn_id,
	sum(qty) as unique_qty
from sales 
group by 1
)
select 
	round(avg(unique_qty),2) as avg_unique_qty
 from in_each_transaction
````
| Average Unique Quantity |
|-------------------------|
|         18.09           |

# According to the number of products
````sql
with in_each_transaction as 
(
	select 
	txn_id,
	count(distinct prod_id) as unique_prod
from sales 
group by 1
)
select 
	round(avg(unique_prod),2) as avg_unique_qty
 from in_each_transaction
````
| Average Unique Quantity |
|-------------------------|
|         6.04            |
## 3.What are the 25th, 50th and 75th percentile values for the revenue per transaction?
````sql	
with txn_revenue_cte as 
(select 
	txn_id,
	sum(price*qty) as txn_revenue 
from sales 
group by 1 )
select 
	 PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY txn_revenue) AS q25_revenue,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY txn_revenue) AS q50_revenue,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY txn_revenue) AS q75_revenue
from txn_revenue_cte
````
| Q25 Revenue | Q50 Revenue | Q75 Revenue |
|-------------|-------------|-------------|
|   375.75    |    509.5    |    647      |

## 4.What is the average discount value per transaction?
	
````sql
with discount_transaction as 
(
select 
	txn_id,
	sum(price*qty*discount/100) as value_discount
from sales 
	group by 1
)
select 
	round(avg(value_discount),2) as avg_discount_value
from discount_transaction
````
| avg_discount_value |
|-------------------|
|       59.79       |

## 5.What is the percentage split of all transactions for members vs non-members?
	 
# ROAD 1
````sql
with txn_transaction as 
(
select 
		member,
		count(distinct txn_id) as transactions 
from sales 
	group by 1
)
select 
	member,
	transactions,
	round((transactions*1.0/(select count(distinct txn_id) from sales)*1.0)*100,2) as ratio
from txn_transaction
````
| member | transactions | ratio  |
|--------|--------------|--------|
| false  | 995          | 39.80  |
| true   | 1505         | 60.20  |

# ROAD 2
````sql
select 
	round(sum(case 
			when member='t' then 1 else 0 end)*100.0/count(*),2) as member,
	round(sum(case 
			when member='f' then 1 else 0 end)*100.0/count(*),2) as non_member
from sales
````
| member    | non_member |
|-----------|------------|
| 60.03     | 39.97      |

