## 🖇️Case Study #7 - Balanced Tree Clothing Co.
## 📎Transaction Analysis

## 1.How many unique transactions were there?
	 
```sql	 
select 
	count(distinct txn_id) as total_transactions 
from sales	
```
## 2.What is the average unique products purchased in each transaction
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
